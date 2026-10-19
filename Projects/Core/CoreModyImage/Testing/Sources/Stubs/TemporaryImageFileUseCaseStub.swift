//
//  TemporaryImageFileUseCaseStub.swift
//  CoreModyImageTesting
//
//  Created by 김동준 on 10/9/26.
//

import CoreModyImageInterface
import Foundation

public struct TemporaryImageFileUseCaseStub: TemporaryImageFileUseCaseProtocol {
    private let saveHandler: (Data, String) throws -> TemporaryImageFile
    private let copyHandler: (URL, String) throws -> TemporaryImageFile
    private let removeHandler: (URL) throws -> Void
    private let cleanupHandler: (TimeInterval) throws -> Void

    public init(
        saveImage: @escaping (Data, String) throws -> TemporaryImageFile = { _, _ in
            throw CoreModyImageStubError.unexpectedCall("saveImage")
        },
        copyImage: @escaping (URL, String) throws -> TemporaryImageFile = { _, _ in
            throw CoreModyImageStubError.unexpectedCall("copyImage")
        },
        removeImage: @escaping (URL) throws -> Void = { _ in
            throw CoreModyImageStubError.unexpectedCall("removeImage")
        },
        removeExpiredImages: @escaping (TimeInterval) throws -> Void = { _ in
            throw CoreModyImageStubError.unexpectedCall("removeExpiredImages")
        }
    ) {
        self.saveHandler = saveImage
        self.copyHandler = copyImage
        self.removeHandler = removeImage
        self.cleanupHandler = removeExpiredImages
    }

    /// 파일 I/O 없이 메타데이터만 반환하는 Demo·Presentation 테스트용 대역입니다.
    public static func metadataOnly(contentType: String = "image/jpeg") -> Self {
        Self(
            saveImage: { _, name in TemporaryImageFileFixture.make(fileName: name, contentType: contentType) },
            copyImage: { url, name in TemporaryImageFileFixture.make(fileURL: url, fileName: name, contentType: contentType) },
            removeImage: { _ in },
            removeExpiredImages: { _ in }
        )
    }

    public func saveImage(data: Data, fileName: String) throws -> TemporaryImageFile {
        try saveHandler(data, fileName)
    }

    public func copyImage(at sourceURL: URL, fileName: String) throws -> TemporaryImageFile {
        try copyHandler(sourceURL, fileName)
    }

    public func removeImage(at fileURL: URL) throws {
        try removeHandler(fileURL)
    }

    public func removeExpiredImages(olderThan expirationInterval: TimeInterval) throws {
        try cleanupHandler(expirationInterval)
    }
}
