//
//  CameraImageRotator.swift
//  CoreCamera
//

import UIKit

enum CameraImageRotation: Int {
    case zero = 0
    case ninety = 90
    case oneEighty = 180
    case twoSeventy = 270

    func adding(clockwise degrees: Int) -> CameraImageRotation {
        CameraImageRotation(rawValue: (rawValue + degrees + 360) % 360) ?? .zero
    }
}

struct CameraImageRotator {
    func rotate(_ image: UIImage, by rotation: CameraImageRotation) -> UIImage {
        guard rotation != .zero else { return image }

        let radians = CGFloat(rotation.rawValue) * .pi / 180
        let rotatedSize = rotation.rawValue.isMultiple(of: 180)
            ? image.size
            : CGSize(width: image.size.height, height: image.size.width)
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale

        return UIGraphicsImageRenderer(size: rotatedSize, format: format).image { context in
            context.cgContext.translateBy(
                x: rotatedSize.width / 2,
                y: rotatedSize.height / 2
            )
            context.cgContext.rotate(by: radians)
            image.draw(in: CGRect(
                x: -image.size.width / 2,
                y: -image.size.height / 2,
                width: image.size.width,
                height: image.size.height
            ))
        }
    }
}
