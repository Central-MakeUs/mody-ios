//
//  CameraImageCropper.swift
//  CoreCamera
//
//  Created by 김동준 on 7/20/26.
//

import UIKit

struct CameraImageCropOutput {
    let croppedImage: UIImage
    let originalImageBounds: CGRect
    let selectionFrameInOriginalImage: CGRect
    let normalizedSelectionFrame: CGRect
}

struct CameraImageCropper {
    func crop(
        image: UIImage,
        selectionFrame: CGRect,
        containerSize: CGSize
    ) -> CameraImageCropOutput? {
        let originalImageBounds = CGRect(origin: .zero, size: image.size)

        guard containerSize.width > 0,
              containerSize.height > 0,
              originalImageBounds.width > 0,
              originalImageBounds.height > 0 else { return nil }

        let aspectFillScale = max(
            containerSize.width / originalImageBounds.width,
            containerSize.height / originalImageBounds.height
        )
        let displayedImageSize = CGSize(
            width: originalImageBounds.width * aspectFillScale,
            height: originalImageBounds.height * aspectFillScale
        )
        let displayedImageOrigin = CGPoint(
            x: (containerSize.width - displayedImageSize.width) / 2,
            y: (containerSize.height - displayedImageSize.height) / 2
        )
        let selectionFrameInOriginalImage = CGRect(
            x: (selectionFrame.minX - displayedImageOrigin.x) / aspectFillScale,
            y: (selectionFrame.minY - displayedImageOrigin.y) / aspectFillScale,
            width: selectionFrame.width / aspectFillScale,
            height: selectionFrame.height / aspectFillScale
        ).intersection(originalImageBounds)

        guard !selectionFrameInOriginalImage.isNull,
              selectionFrameInOriginalImage.width > 0,
              selectionFrameInOriginalImage.height > 0 else { return nil }

        let normalizedSelectionFrame = CGRect(
            x: selectionFrameInOriginalImage.minX / originalImageBounds.width,
            y: selectionFrameInOriginalImage.minY / originalImageBounds.height,
            width: selectionFrameInOriginalImage.width / originalImageBounds.width,
            height: selectionFrameInOriginalImage.height / originalImageBounds.height
        )
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = image.scale
        let croppedImage = UIGraphicsImageRenderer(
            size: selectionFrameInOriginalImage.size,
            format: rendererFormat
        ).image { _ in
            image.draw(
                at: CGPoint(
                    x: -selectionFrameInOriginalImage.minX,
                    y: -selectionFrameInOriginalImage.minY
                )
            )
        }

        return CameraImageCropOutput(
            croppedImage: croppedImage,
            originalImageBounds: originalImageBounds,
            selectionFrameInOriginalImage: selectionFrameInOriginalImage,
            normalizedSelectionFrame: normalizedSelectionFrame
        )
    }
}
