//
//  CameraImageThumbnailGenerator.swift
//  CoreCamera
//
//  Created by 김동준 on 7/25/26.
//

import Foundation
import ImageIO
import UIKit

/// ImageIO가 디코딩 단계에서 축소하도록 해 원본 해상도만큼의 픽셀 메모리를 만들지 않습니다.
struct CameraImageThumbnailGenerator {
    func makeThumbnail(
        fileURL: URL,
        maxPixelSize: Int
    ) -> UIImage? {
        autoreleasepool {
            guard maxPixelSize > 0,
                  let imageSource = CGImageSourceCreateWithURL(
                    fileURL as CFURL,
                    [kCGImageSourceShouldCache: false] as CFDictionary
                  ),
                  let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, [
                        kCGImageSourceCreateThumbnailFromImageAlways: true,
                        kCGImageSourceCreateThumbnailWithTransform: true,
                        kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
                        kCGImageSourceShouldCacheImmediately: true
                    ] as CFDictionary
                  ) else {
                return nil
            }

            return UIImage(cgImage: cgImage, scale: 1, orientation: .up)
        }
    }
}
