//
//  NormalizedCropProcessor.swift
//  CoreModyImage
//
//  Created by 김동준 on 7/25/26.
//

import CoreModyImageInterface
import Nuke
import UIKit

struct NormalizedCropProcessor: ImageProcessing, Hashable {
    private static let version = "v1"

    private let normalizedCrop: NormalizedImageCropInfo?
    private let outputPixelSize: CGSize

    init(
        normalizedCrop: NormalizedImageCropInfo?,
        outputPixelSize: CGSize
    ) {
        self.normalizedCrop = normalizedCrop
        self.outputPixelSize = outputPixelSize
    }

    func process(_ image: UIImage) -> UIImage? {
        autoreleasepool {
            // 서버의 normalized 영역을 먼저 적용하고 최종 표시 크기로 한 번만 resize 합니다.
            let cropSource = croppedImage(from: image) ?? image
            return ImageProcessors.Resize(
                size: outputPixelSize,
                unit: .pixels,
                contentMode: .aspectFill,
                crop: true,
                upscale: true
            )
            .process(cropSource)
        }
    }

    /// Nuke가 crop 좌표와 출력 크기가 다른 가공 결과를 별도 캐시 항목으로 구분합니다.
    var identifier: String {
        [
            "com.mody.core-image.normalized-crop",
            Self.version,
            normalizedCrop.map(Self.cropIdentifier) ?? "none",
            Self.sizeIdentifier(outputPixelSize)
        ].joined(separator: "|")
    }
}

private extension NormalizedCropProcessor {
    func croppedImage(from image: UIImage) -> UIImage? {
        guard let normalizedCrop,
              let cgImage = image.cgImage else {
            return nil
        }

        let imageRect = CGRect(
            x: 0,
            y: 0,
            width: cgImage.width,
            height: cgImage.height
        )
        let cropRect = CGRect(
            x: normalizedCrop.x * imageRect.width,
            y: normalizedCrop.y * imageRect.height,
            width: normalizedCrop.width * imageRect.width,
            height: normalizedCrop.height * imageRect.height
        )
        .integral
        .intersection(imageRect)

        guard !cropRect.isEmpty,
              let croppedImage = cgImage.cropping(to: cropRect) else {
            return nil
        }

        return UIImage(cgImage: croppedImage, scale: 1, orientation: .up)
    }

    static func cropIdentifier(_ crop: NormalizedImageCropInfo) -> String {
        [
            fixed(crop.x),
            fixed(crop.y),
            fixed(crop.width),
            fixed(crop.height)
        ].joined(separator: ",")
    }

    static func sizeIdentifier(_ size: CGSize) -> String {
        "\(Int(size.width.rounded()))x\(Int(size.height.rounded()))"
    }

    static func fixed(_ value: CGFloat) -> String {
        String(format: "%.6f", locale: Locale(identifier: "en_US_POSIX"), value)
    }
}
