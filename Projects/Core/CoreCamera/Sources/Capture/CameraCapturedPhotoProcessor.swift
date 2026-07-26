//
//  CameraCapturedPhotoProcessor.swift
//  CoreCamera
//
//  Created by 김동준 on 7/25/26.
//

import CoreModyImageInterface
import Foundation
import UIKit

struct CameraCapturedPhoto {
    let originalFile: TemporaryImageFile
    let previewImage: UIImage
}

/// 일시적인 카메라·앨범 입력을 앱 소유 원본 파일과 제한된 크기의 미리보기로 변환합니다.
///
/// 화면 상태나 ViewController에 접근하지 않으므로 main queue가 보장되지 않는 캡처 콜백에서도 호출할 수 있습니다.
struct CameraCapturedPhotoProcessor {
    private let temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol
    private let thumbnailGenerator: CameraImageThumbnailGenerator
    private let previewMaxPixelSize: Int

    init(
        temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol,
        thumbnailGenerator: CameraImageThumbnailGenerator = CameraImageThumbnailGenerator(),
        previewMaxPixelSize: Int
    ) {
        self.temporaryImageFileUseCase = temporaryImageFileUseCase
        self.thumbnailGenerator = thumbnailGenerator
        self.previewMaxPixelSize = previewMaxPixelSize
    }

    func makeCapturedPhoto(
        data: Data,
        fileName: String
    ) throws -> CameraCapturedPhoto {
        let originalFile = try temporaryImageFileUseCase.saveImage(
            data: data,
            fileName: fileName
        )
        return try makeCapturedPhoto(originalFile: originalFile)
    }

    func makeCapturedPhoto(
        fileURL: URL,
        fileName: String
    ) throws -> CameraCapturedPhoto {
        // PHPicker의 fileURL처럼 콜백 수명에 묶인 파일을 먼저 앱 임시 영역으로 분리합니다.
        let originalFile = try temporaryImageFileUseCase.copyImage(
            at: fileURL,
            fileName: fileName
        )
        return try makeCapturedPhoto(originalFile: originalFile)
    }

    func removeCapturedPhoto(_ capturedPhoto: CameraCapturedPhoto) {
        try? temporaryImageFileUseCase.removeImage(
            at: capturedPhoto.originalFile.fileURL
        )
    }
}

private extension CameraCapturedPhotoProcessor {
    func makeCapturedPhoto(
        originalFile: TemporaryImageFile
    ) throws -> CameraCapturedPhoto {
        // 원본 전체를 UIImage로 디코딩하지 않고 화면 확인에 필요한 크기로만 로드합니다.
        guard let previewImage = thumbnailGenerator.makeThumbnail(
            fileURL: originalFile.fileURL,
            maxPixelSize: previewMaxPixelSize
        ) else {
            try? temporaryImageFileUseCase.removeImage(at: originalFile.fileURL)
            throw CocoaError(.fileReadCorruptFile)
        }

        return CameraCapturedPhoto(
            originalFile: originalFile,
            previewImage: previewImage
        )
    }
}
