//
//  TemporaryImageFileFixture.swift
//  CoreModyImageTesting
//
//  Created by 김동준 on 10/9/26.
//

import CoreModyImageInterface
import Foundation

public enum TemporaryImageFileFixture {
    /// 메타데이터만 만들며 실제 파일은 생성하지 않습니다.
    public static func make(
        fileURL: URL? = nil,
        fileName: String = "image.jpg",
        contentType: String = "image/jpeg"
    ) -> TemporaryImageFile {
        TemporaryImageFile(
            fileURL: fileURL ?? URL(fileURLWithPath: "/tmp").appendingPathComponent(fileName),
            fileName: fileName,
            contentType: contentType
        )
    }
}
