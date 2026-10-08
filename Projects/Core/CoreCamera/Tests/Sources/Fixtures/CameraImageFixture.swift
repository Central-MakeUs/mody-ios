//  CameraImageFixture.swift
//  CoreCameraTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreCameraTesting
import UIKit

@testable import CoreCamera

enum CameraImageFixture {
    static func image(size: CGSize = CGSize(width: 80, height: 40), scale: CGFloat = 1) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            UIColor.blue.setFill()
            context.fill(CGRect(x: size.width / 2, y: 0, width: size.width / 2, height: size.height))
        }
    }

    static func photo(fileName: String = "photo.png") -> CameraCapturedPhoto {
        let result = CameraCaptureResultFixture.make(previewImage: image(), fileName: fileName)
        return CameraCapturedPhoto(originalFile: result.originalFile, previewImage: result.croppedPreviewImage)
    }
}
