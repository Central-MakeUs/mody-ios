//
//  CameraCaptureResult.swift
//  CoreCameraInterface
//
//  Created by 김동준 on 7/20/26.
//

import UIKit

public struct CameraCaptureResult {
    public let image: UIImage
    public let croppedImage: UIImage
    public let normalizedSelectionFrame: CGRect
    public let originalFileName: String

    public init(
        image: UIImage,
        croppedImage: UIImage,
        normalizedSelectionFrame: CGRect,
        originalFileName: String
    ) {
        self.image = image
        self.croppedImage = croppedImage
        self.normalizedSelectionFrame = normalizedSelectionFrame
        self.originalFileName = originalFileName
    }
}
