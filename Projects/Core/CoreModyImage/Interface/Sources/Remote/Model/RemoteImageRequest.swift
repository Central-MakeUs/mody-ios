//
//  RemoteImageRequest.swift
//  CoreModyImageInterface
//
//  Created by 김동준 on 7/25/26.
//

import CoreGraphics
import Foundation

/// 원격 이미지의 원본, 디코딩 크기, 가공 결과를 하나의 캐시 단위로 표현합니다.
public struct RemoteImageRequest: Hashable, Sendable {
    public let url: URL
    public let variantIdentifier: String
    public let maximumPixelSize: Int
    public let processing: RemoteImageProcessing

    public init(
        url: URL,
        variantIdentifier: String,
        maximumPixelSize: Int,
        processing: RemoteImageProcessing = .none
    ) {
        self.url = url
        self.variantIdentifier = variantIdentifier
        self.maximumPixelSize = max(1, maximumPixelSize)
        self.processing = processing
    }

    /// 같은 URL이라도 용도·크기·crop이 다르면 별도 결과로 캐싱하기 위한 식별자입니다.
    public var identity: String {
        [
            url.absoluteString,
            variantIdentifier,
            "decode=\(maximumPixelSize)",
            processing.identity
        ].joined(separator: "|")
    }
}

private extension RemoteImageProcessing {
    var identity: String {
        switch self {
        case .none:
            return "processing=none"

        case let .aspectFill(pixelSize, normalizedCrop):
            return [
                "processing=aspect-fill-v1",
                "output=\(Self.sizeIdentifier(pixelSize))",
                normalizedCrop.map(Self.cropIdentifier) ?? "crop=none"
            ].joined(separator: "|")
        }
    }

    static func sizeIdentifier(_ size: CGSize) -> String {
        "\(Int(size.width.rounded()))x\(Int(size.height.rounded()))"
    }

    static func cropIdentifier(_ crop: NormalizedImageCropInfo) -> String {
        [
            fixed(crop.x),
            fixed(crop.y),
            fixed(crop.width),
            fixed(crop.height)
        ].joined(separator: ",")
    }

    static func fixed(_ value: CGFloat) -> String {
        String(
            format: "%.6f",
            locale: Locale(identifier: "en_US_POSIX"),
            value
        )
    }
}
