//
//  FeedImageRequestFactory.swift
//  Feed
//
//  Created by 김동준 on 7/25/26.
//

import CoreModyImageInterface
import UIKit

struct FeedImageRequestFactory {
    static let recordDecodeLongSide = 2048

    static func makeRecordRequest(
        url: URL,
        cropRegion: FeedImageCropRegion?,
        displaySize: CGSize,
        displayScale: CGFloat
    ) -> RemoteImageRequest? {
        guard let targetSize = FeedImageTargetSize.make(
            displaySize: displaySize,
            displayScale: displayScale
        ) else {
            return nil
        }
        return RemoteImageRequest(
            url: url,
            variantIdentifier: "feed-record-\(targetSize.longSideBucket)",
            maximumPixelSize: recordDecodeLongSide,
            processing: .aspectFill(
                pixelSize: targetSize.pixelSize,
                normalizedCrop: cropRegion.flatMap {
                    NormalizedImageCropInfo(
                        x: $0.x,
                        y: $0.y,
                        width: $0.width,
                        height: $0.height
                    )
                }
            )
        )
    }
}
