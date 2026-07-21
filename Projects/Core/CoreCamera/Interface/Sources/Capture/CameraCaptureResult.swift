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

    public init(
        image: UIImage,
        croppedImage: UIImage,
        normalizedSelectionFrame: CGRect
    ) {
        self.image = image
        self.croppedImage = croppedImage
        self.normalizedSelectionFrame = normalizedSelectionFrame
    }
}
