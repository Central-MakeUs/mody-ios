//
//  NormalizedImageCropInfo.swift
//  CoreModyImageInterface
//
//  Created by 김동준 on 7/25/26.
//

import CoreGraphics
import Foundation

public struct NormalizedImageCropInfo: Hashable, Sendable {
    public let x: CGFloat
    public let y: CGFloat
    public let width: CGFloat
    public let height: CGFloat

    public init?(
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat
    ) {
        guard x.isFinite,
              y.isFinite,
              width.isFinite,
              height.isFinite,
              width > 0,
              height > 0 else {
            return nil
        }

        let normalizedX = min(max(x, 0), 1)
        let normalizedY = min(max(y, 0), 1)
        let normalizedWidth = min(width, 1 - normalizedX)
        let normalizedHeight = min(height, 1 - normalizedY)

        guard normalizedWidth > 0, normalizedHeight > 0 else {
            return nil
        }

        self.x = normalizedX
        self.y = normalizedY
        self.width = normalizedWidth
        self.height = normalizedHeight
    }
}
