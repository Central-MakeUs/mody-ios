//
//  CameraImageCropper.swift
//  CoreCamera
//
//  Created by 김동준 on 7/20/26.
//

import UIKit

/// 화면의 선택 영역을 잘라낸 미리보기와 해상도 독립적인 정규화 좌표입니다.
struct CameraImageCropOutput {
    let croppedImage: UIImage
    let normalizedSelectionFrame: CGRect
}

enum CameraImageDisplayMode {
    case aspectFill
    case aspectFit
}

struct CameraDisplayedImageLayout {
    let originalImageBounds: CGRect
    let displayedImageFrame: CGRect

    static func make(
        imageSize: CGSize,
        containerSize: CGSize,
        displayMode: CameraImageDisplayMode
    ) -> CameraDisplayedImageLayout? {
        let originalImageBounds = CGRect(origin: .zero, size: imageSize)

        guard containerSize.width > 0,
              containerSize.height > 0,
              originalImageBounds.width > 0,
              originalImageBounds.height > 0 else { return nil }

        let scale: CGFloat
        switch displayMode {
        case .aspectFill:
            scale = max(
                containerSize.width / originalImageBounds.width,
                containerSize.height / originalImageBounds.height
            )
        case .aspectFit:
            scale = min(
                containerSize.width / originalImageBounds.width,
                containerSize.height / originalImageBounds.height
            )
        }

        let displayedImageSize = CGSize(
            width: originalImageBounds.width * scale,
            height: originalImageBounds.height * scale
        )
        let displayedImageFrame = CGRect(
            x: (containerSize.width - displayedImageSize.width) / 2,
            y: (containerSize.height - displayedImageSize.height) / 2,
            width: displayedImageSize.width,
            height: displayedImageSize.height
        )

        return CameraDisplayedImageLayout(
            originalImageBounds: originalImageBounds,
            displayedImageFrame: displayedImageFrame
        )
    }
}

struct CameraImageCropper {
    /// 선택 영역을 화면용 입력 이미지에서 자르고, 원본 파일에도 적용 가능한 0...1 좌표를 계산합니다.
    func crop(
        image: UIImage,
        selectionFrame: CGRect,
        containerSize: CGSize,
        displayMode: CameraImageDisplayMode = .aspectFill
    ) -> CameraImageCropOutput? {
        guard let layout = CameraDisplayedImageLayout.make(
            imageSize: image.size,
            containerSize: containerSize,
            displayMode: displayMode
        ) else { return nil }

        let originalImageBounds = layout.originalImageBounds
        let displayedImageFrame = layout.displayedImageFrame
        let displayScale = displayedImageFrame.width / originalImageBounds.width
        let selectionFrameInOriginalImage = CGRect(
            x: (selectionFrame.minX - displayedImageFrame.minX) / displayScale,
            y: (selectionFrame.minY - displayedImageFrame.minY) / displayScale,
            width: selectionFrame.width / displayScale,
            height: selectionFrame.height / displayScale
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
        rendererFormat.scale = 1
        let croppedImage = UIGraphicsImageRenderer(
            size: selectionFrameInOriginalImage.size,
            format: rendererFormat
        ).image { _ in
            image.draw(
                in: CGRect(
                    x: -selectionFrameInOriginalImage.minX,
                    y: -selectionFrameInOriginalImage.minY,
                    width: originalImageBounds.width,
                    height: originalImageBounds.height
                )
            )
        }

        return CameraImageCropOutput(
            croppedImage: croppedImage,
            normalizedSelectionFrame: normalizedSelectionFrame
        )
    }
}
