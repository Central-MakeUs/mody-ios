//
//  RemoteImageProcessing.swift
//  CoreModyImageInterface
//
//  Created by 김동준 on 7/25/26.
//

import CoreGraphics

/// 다운로드한 이미지를 화면에 전달하기 전에 적용할 가공 정책입니다.
public enum RemoteImageProcessing: Hashable, Sendable {
    case none

    /// normalized crop 영역을 먼저 자른 뒤 지정한 픽셀 크기에 aspect fill 합니다.
    case aspectFill(
        pixelSize: CGSize,
        normalizedCrop: NormalizedImageCropInfo?
    )
}
