//
//  CameraCaptureResult.swift
//  CoreCameraInterface
//
//  Created by 김동준 on 7/20/26.
//

import CoreModyImageInterface
import UIKit

/// 촬영 완료 후 호출자에게 전달되는 원본 파일과 화면용 크롭 정보입니다.
public struct CameraCaptureResult {
    public let originalFile: TemporaryImageFile
    /// 화면 표시용으로 다운샘플된 이미지에서 만든 크롭 미리보기입니다.
    public let croppedPreviewImage: UIImage
    public let normalizedSelectionFrame: CGRect

    public init(
        originalFile: TemporaryImageFile,
        croppedPreviewImage: UIImage,
        normalizedSelectionFrame: CGRect
    ) {
        self.originalFile = originalFile
        self.croppedPreviewImage = croppedPreviewImage
        self.normalizedSelectionFrame = normalizedSelectionFrame
    }
}
