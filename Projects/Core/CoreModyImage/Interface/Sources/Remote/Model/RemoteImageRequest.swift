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
    /// 단일 원격 이미지가 과도한 픽셀 버퍼를 만들지 않도록 제한하는 절대 상한입니다.
    public static let maximumAllowedPixelSize = 2048

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
        self.maximumPixelSize = min(
            max(1, maximumPixelSize),
            Self.maximumAllowedPixelSize
        )
        self.processing = processing.bounded(
            maximumPixelSize: self.maximumPixelSize
        )
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
    func bounded(maximumPixelSize: Int) -> RemoteImageProcessing {
        switch self {
        case .none:
            return .none

        case let .aspectFill(pixelSize, normalizedCrop):
            let width = Self.validPixelDimension(pixelSize.width)
            let height = Self.validPixelDimension(pixelSize.height)
            let longSide = max(width, height)
            let scale = min(1, CGFloat(maximumPixelSize) / longSide)

            return .aspectFill(
                pixelSize: CGSize(
                    width: max(1, (width * scale).rounded(.up)),
                    height: max(1, (height * scale).rounded(.up))
                ),
                normalizedCrop: normalizedCrop
            )
        }
    }

    static func validPixelDimension(_ value: CGFloat) -> CGFloat {
        guard value.isFinite, value > 0 else { return 1 }
        return value
    }

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
