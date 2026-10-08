//  ChallengeImageSpy.swift
//  ChallengeTests
//
//  Created by 김동준 on 10/6/26.
//

import CommonDomain
import CoreModyImageInterface
import Foundation
import XCTest

final class ChallengeImageSpy: ImageUploadUseCaseProtocol, TemporaryImageFileUseCaseProtocol, @unchecked Sendable {
    struct Upload: Equatable {
        let fileURL: URL
        let fileName: String
        let domain: ImageUploadDomain
    }

    private let lock = NSLock()
    private let uploadResult: Result<String, NetworkError>
    private var recordedUploads: [Upload] = []
    private var recordedRemovals: [URL] = []

    var uploads: [Upload] { lock.withLock { recordedUploads } }
    var removedURLs: [URL] { lock.withLock { recordedRemovals } }

    init(uploadResult: Result<String, NetworkError> = .success("uploaded-proof")) {
        self.uploadResult = uploadResult
    }

    func uploadImage(fileURL: URL, fileName: String, domain: ImageUploadDomain) async throws -> String {
        lock.withLock { recordedUploads.append(Upload(fileURL: fileURL, fileName: fileName, domain: domain)) }
        return try uploadResult.get()
    }

    func saveImage(data: Data, fileName: String) throws -> TemporaryImageFile {
        XCTFail("Unexpected image save")
        throw NetworkError.unknown
    }

    func copyImage(at sourceURL: URL, fileName: String) throws -> TemporaryImageFile {
        XCTFail("Unexpected image copy")
        throw NetworkError.unknown
    }

    func removeImage(at fileURL: URL) throws {
        lock.withLock { recordedRemovals.append(fileURL) }
    }

    func removeExpiredImages(olderThan expirationInterval: TimeInterval) throws {
        XCTFail("Unexpected image cleanup")
    }
}
