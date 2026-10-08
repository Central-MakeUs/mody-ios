//  CameraCaptureResultFixture.swift
//  CoreCameraTesting
//
//  Created by 김동준 on 10/9/26.
//

import CoreCameraInterface
import CoreModyImageInterface
import UIKit

public enum CameraCaptureResultFixture {
    /// 파일 I/O 없이 외부 카메라의 완료 값을 조립합니다. 실제 파일이 필요하면 fileURL을 전달합니다.
    public static func make(
        previewImage: UIImage,
        fileName: String,
        fileURL: URL? = nil
    ) -> CameraCaptureResult {
        CameraCaptureResult(
            originalFile: TemporaryImageFile(
                fileURL: fileURL ?? URL(fileURLWithPath: "/tmp").appendingPathComponent(fileName),
                fileName: fileName,
                contentType: "image/jpeg"
            ),
            croppedPreviewImage: previewImage,
            normalizedSelectionFrame: CGRect(x: 0, y: 0, width: 1, height: 1)
        )
    }
}
