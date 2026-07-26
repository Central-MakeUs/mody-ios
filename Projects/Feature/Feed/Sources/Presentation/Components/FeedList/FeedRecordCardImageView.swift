//
//  FeedRecordCardImageView.swift
//  Feed
//
//  Created by 김동준 on 7/21/26
//

import CoreModyImageInterface
import UIKit
import DesignSystem
import SnapKit

final class FeedRecordCardImageView: UIView {
    private let imageView = UIImageView()
    private let skeletonView = UISkeletonView(width: 1, height: 1)
    private var imageLoader: RemoteImageLoading?
    private var requestSource: ImageRequestSource?
    private var currentRequestIdentity: String?
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

    override func layoutSubviews() {
        super.layoutSubviews()
        loadImageIfNeeded()
    }

    func prepareForReuse() {
        requestSource = nil
        currentRequestIdentity = nil
        imageLoader = nil
        fallbackImage = nil
        imageView.image = nil
        stopSkeleton()
    }

    func configure(
        request: RemoteImageRequest?,
        cornerRadius: CGFloat,
        fallbackImage: UIImage? = nil,
        imageLoader: RemoteImageLoading
    ) {
        applyConfiguration(
            requestSource: request.map(ImageRequestSource.preconfigured),
            cornerRadius: cornerRadius,
            fallbackImage: fallbackImage,
            imageLoader: imageLoader
        )
    }

    func configureRecord(
        urlString: String?,
        cropRegion: FeedImageCropRegion?,
        cornerRadius: CGFloat,
        imageLoader: RemoteImageLoading
    ) {
        let requestSource = FeedImageURLResolver.resolve(urlString).map {
            ImageRequestSource.record(url: $0, cropRegion: cropRegion)
        }
        applyConfiguration(
            requestSource: requestSource,
            cornerRadius: cornerRadius,
            fallbackImage: nil,
            imageLoader: imageLoader
        )
    }
}

private extension FeedRecordCardImageView {
    enum ImageRequestSource {
        case preconfigured(RemoteImageRequest)
        case record(url: URL, cropRegion: FeedImageCropRegion?)

        func makeRequest(
            displaySize: CGSize,
            displayScale: CGFloat
        ) -> RemoteImageRequest? {
            switch self {
            case let .preconfigured(request):
                return request

            case let .record(url, cropRegion):
                return FeedImageRequestFactory.makeRecordRequest(
                    url: url,
                    cropRegion: cropRegion,
                    displaySize: displaySize,
                    displayScale: displayScale
                )
            }
        }
    }

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

    func applyConfiguration(
        requestSource: ImageRequestSource?,
        cornerRadius: CGFloat,
        fallbackImage: UIImage?,
        imageLoader: RemoteImageLoading
    ) {
        currentRequestIdentity = nil
        self.requestSource = requestSource
        self.imageLoader = imageLoader
        self.fallbackImage = fallbackImage
        layer.cornerRadius = cornerRadius
        imageView.layer.cornerRadius = cornerRadius
        skeletonView.layer.cornerRadius = cornerRadius

        guard requestSource != nil else {
            showFallback()
            return
        }

        imageView.image = nil
        loadImageIfNeeded()
    }

    func loadImageIfNeeded() {
        guard let requestSource,
              let imageLoader,
              let request = requestSource.makeRequest(
                displaySize: bounds.size,
                displayScale: traitCollection.displayScale
              ),
              request.identity != currentRequestIdentity else {
            return
        }

        currentRequestIdentity = request.identity

        if let cachedImage = imageLoader.cachedImage(for: request) {
            imageView.image = cachedImage
            stopSkeleton()
            return
        }

        imageView.image = nil
        skeletonView.isHidden = false
        skeletonView.startAnimating()

        Task { @MainActor [weak self, imageLoader] in
            let image = try? await imageLoader.loadImage(with: request)
            guard let self,
                  self.currentRequestIdentity == request.identity else {
                return
            }

            guard let image else {
                self.showFallback()
                return
            }

            self.imageView.image = image
            self.stopSkeleton()
        }
    }

    func showFallback() {
        imageView.image = fallbackImage
        stopSkeleton()
    }

    func stopSkeleton() {
        skeletonView.isHidden = true
        skeletonView.stopAnimating()
    }
}
