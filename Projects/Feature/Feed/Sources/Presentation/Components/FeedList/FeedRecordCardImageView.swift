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
    private var currentURLString: String?

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
        cropRegion: FeedImageCropRegion? = nil
    ) {
        imageTask?.cancel()
        currentURLString = urlString
        layer.cornerRadius = cornerRadius
        imageView.layer.cornerRadius = cornerRadius
        skeletonView.layer.cornerRadius = cornerRadius
        imageView.layer.contentsRect = cropRegion?.normalizedContentsRect ?? CGRect(x: 0, y: 0, width: 1, height: 1)

        guard let urlString,
              !urlString.isEmpty,
              let url = URL(string: urlString) else {
            imageView.image = nil
            skeletonView.isHidden = true
            skeletonView.stopAnimating()
            return
        }

        if let cachedImage = Self.imageCache.object(forKey: urlString as NSString) {
            imageView.image = cachedImage
            skeletonView.isHidden = true
            skeletonView.stopAnimating()
            return
        }

        imageView.image = nil
        skeletonView.isHidden = false
        skeletonView.startAnimating()

        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self,
                  let data,
                  let image = UIImage(data: data) else {
                return
            }

            Self.imageCache.setObject(image, forKey: urlString as NSString)

            DispatchQueue.main.async {
                guard self.currentURLString == urlString else { return }
                self.imageView.image = image
                self.skeletonView.isHidden = true
                self.skeletonView.stopAnimating()
            }
        }
        imageTask?.resume()
    }

    func prepareForReuse() {
        imageTask?.cancel()
        currentURLString = nil
        imageView.image = nil
        imageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
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
}

private extension FeedImageCropRegion {
    var normalizedContentsRect: CGRect? {
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
