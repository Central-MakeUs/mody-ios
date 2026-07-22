//
//  FeedRecordCardImageView.swift
//  Feed
//
//  Created by 김동준 on 7/21/26
//

import UIKit
import DesignSystem
import SnapKit

final class FeedRecordCardImageView: UIView {
    private static let imageCache = NSCache<NSString, UIImage>()

    private let imageView = UIImageView()
    private let skeletonView = UISkeletonView(width: 1, height: 1)
    private var imageTask: URLSessionDataTask?
    private var currentCacheKey: String?
    private var fallbackImage: UIImage?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        imageTask?.cancel()
    }

    func configure(
        urlString: String?,
        cornerRadius: CGFloat,
        cropRegion: FeedImageCropRegion? = nil,
        fallbackImage: UIImage? = nil
    ) {
        imageTask?.cancel()
        self.fallbackImage = fallbackImage
        layer.cornerRadius = cornerRadius
        imageView.layer.cornerRadius = cornerRadius
        skeletonView.layer.cornerRadius = cornerRadius

        guard let url = Self.imageURL(from: urlString) else {
            currentCacheKey = nil
            imageView.image = fallbackImage
            skeletonView.isHidden = true
            skeletonView.stopAnimating()
            return
        }

        let cacheKey = Self.cacheKey(urlString: url.absoluteString, cropRegion: cropRegion)
        currentCacheKey = cacheKey

        if let cachedImage = Self.imageCache.object(forKey: cacheKey as NSString) {
            imageView.image = cachedImage
            skeletonView.isHidden = true
            skeletonView.stopAnimating()
            return
        }

        imageView.image = nil
        skeletonView.isHidden = false
        skeletonView.startAnimating()

        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }

            guard let data,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    guard self.currentCacheKey == cacheKey else { return }
                    self.imageView.image = self.fallbackImage
                    self.skeletonView.isHidden = true
                    self.skeletonView.stopAnimating()
                }
                return
            }

            let displayImage = image.cropped(to: cropRegion) ?? image
            Self.imageCache.setObject(displayImage, forKey: cacheKey as NSString)

            DispatchQueue.main.async {
                guard self.currentCacheKey == cacheKey else { return }
                self.imageView.image = displayImage
                self.skeletonView.isHidden = true
                self.skeletonView.stopAnimating()
            }
        }
        imageTask?.resume()
    }

    func prepareForReuse() {
        imageTask?.cancel()
        currentCacheKey = nil
        fallbackImage = nil
        imageView.image = nil
        skeletonView.isHidden = true
        skeletonView.stopAnimating()
    }

}

private extension FeedRecordCardImageView {
    func setupUI() {
        backgroundColor = .gray1
        clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        skeletonView.isHidden = true
    }

    func setupLayout() {
        addSubview(imageView)
        addSubview(skeletonView)

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        skeletonView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    static func cacheKey(
        urlString: String,
        cropRegion: FeedImageCropRegion?
    ) -> String {
        guard let cropRegion else { return urlString }

        return [
            urlString,
            cropRegion.x.description,
            cropRegion.y.description,
            cropRegion.width.description,
            cropRegion.height.description
        ].joined(separator: "|")
    }

    static func imageURL(from urlString: String?) -> URL? {
        guard let urlString else { return nil }

        let trimmedURLString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURLString.isEmpty else { return nil }

        if let nestedURLString = nestedImageURLString(from: trimmedURLString),
           let nestedURL = URL(string: nestedURLString) {
            return nestedURL
        }

        if let url = URL(string: trimmedURLString) {
            return url
        }

        return URL(string: trimmedURLString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? "")
    }

    static func nestedImageURLString(from urlString: String) -> String? {
        let markers = ["https://", "http://"]

        for marker in markers {
            let ranges = urlString.ranges(of: marker)
            guard ranges.count > 1,
                  let nestedRange = ranges.dropFirst().last else {
                continue
            }

            var nestedURLString = String(urlString[nestedRange.lowerBound...])
            if nestedURLString.hasPrefix("http://") {
                nestedURLString = "https://" + nestedURLString.dropFirst("http://".count)
            }
            return nestedURLString
        }

        return nil
    }
}

private extension String {
    func ranges(of string: String) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var searchStartIndex = startIndex

        while searchStartIndex < endIndex,
              let range = range(of: string, range: searchStartIndex..<endIndex) {
            ranges.append(range)
            searchStartIndex = range.upperBound
        }

        return ranges
    }
}

private extension FeedImageCropRegion {
    var normalizedCropRect: CGRect? {
        guard width > 0, height > 0 else { return nil }

        let originX = min(max(x, 0), 1)
        let originY = min(max(y, 0), 1)
        let maxWidth = max(1 - originX, 0)
        let maxHeight = max(1 - originY, 0)
        let normalizedWidth = min(max(width, 0), maxWidth)
        let normalizedHeight = min(max(height, 0), maxHeight)

        guard normalizedWidth > 0, normalizedHeight > 0 else { return nil }

        return CGRect(
            x: originX,
            y: originY,
            width: normalizedWidth,
            height: normalizedHeight
        )
    }
}

private extension UIImage {
    func cropped(to cropRegion: FeedImageCropRegion?) -> UIImage? {
        guard let normalizedCropRect = cropRegion?.normalizedCropRect else {
            return nil
        }

        let image = normalizedOrientation()
        guard let cgImage = image.cgImage else { return nil }

        let imageRect = CGRect(
            x: 0,
            y: 0,
            width: CGFloat(cgImage.width),
            height: CGFloat(cgImage.height)
        )
        let cropRect = CGRect(
            x: normalizedCropRect.origin.x * imageRect.width,
            y: normalizedCropRect.origin.y * imageRect.height,
            width: normalizedCropRect.width * imageRect.width,
            height: normalizedCropRect.height * imageRect.height
        )
        .integral
        .intersection(imageRect)

        guard !cropRect.isEmpty,
              let croppedImage = cgImage.cropping(to: cropRect) else {
            return nil
        }

        return UIImage(cgImage: croppedImage, scale: image.scale, orientation: .up)
    }

    func normalizedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
