//
//  TemporaryImageFile.swift
//  CoreModyImageInterface
//
//  Created by 김동준 on 7/25/26.
//

import Foundation

public struct TemporaryImageFile: Equatable, Sendable {
    public let fileURL: URL
    public let fileName: String

    /// 파일 확장자가 아니라 실제 이미지 데이터에서 판별한 MIME 타입입니다.
    public let contentType: String

    public init(
        fileURL: URL,
        fileName: String,
        contentType: String
    ) {
        self.fileURL = fileURL
        self.fileName = fileName
        self.contentType = contentType
    }
}
