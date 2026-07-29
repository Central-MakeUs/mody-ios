//
//  FeedImageTargetSize.swift
//  Feed
//
//  Created by 김동준 on 7/25/26.
//

import CoreGraphics

struct FeedImageTargetSize: Equatable {
    static let pixelBuckets = [256, 512, 1024, 2048]

    let pixelSize: CGSize
    let longSideBucket: Int

    static func make(
        displaySize: CGSize,
        displayScale: CGFloat
    ) -> FeedImageTargetSize? {
        let pixelWidth = displaySize.width * displayScale
        let pixelHeight = displaySize.height * displayScale
        let displayLongSide = max(pixelWidth, pixelHeight)

        guard pixelWidth > 0,
              pixelHeight > 0,
              displayLongSide.isFinite else {
            return nil
        }

        let bucket = pixelBuckets.first(where: { CGFloat($0) >= displayLongSide })
            ?? pixelBuckets[pixelBuckets.count - 1]
        let scale = CGFloat(bucket) / displayLongSide
        let pixelSize = CGSize(
            width: max(1, (pixelWidth * scale).rounded(.up)),
            height: max(1, (pixelHeight * scale).rounded(.up))
        )

        return FeedImageTargetSize(
            pixelSize: pixelSize,
            longSideBucket: bucket
        )
    }
}
