//
//  ImageUploadUseCaseTests.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 10/9/26.
//

import CommonDomain
import CoreModyImageInterface
import Foundation
import XCTest
@testable import CoreModyImage

final class ImageUploadUseCaseTests: XCTestCase {
    private let sourceURL = URL(fileURLWithPath: "/tmp/original.heic")

    func testProfileUploadConvertsOnlyFileNameAndUses640PixelPolicy() async throws {
        let repository = ImageUploadRepositorySpy()
        let useCase = ImageUploadUseCase(repository: repository)
        let result = try await useCase.uploadImage(fileURL: sourceURL, fileName: "my.profile.heic", domain: .profile)

        XCTAssertEqual(result, "image-key")
        XCTAssertEqual(repository.presignedCalls, [.init(domain: .profile, fileName: "my.profile.jpg")])
        XCTAssertEqual(repository.uploads, [.init(
            fileURL: sourceURL, destinationURL: URL(string: "https://upload.invalid/image")!, maximumPixelSize: 640
        )])
        XCTAssertEqual(repository.events, ["presigned", "upload"])
    }

    func testRecordUploadPreservesFileNameAndOriginalUploadPolicy() async throws {
        let repository = ImageUploadRepositorySpy()
        let useCase = ImageUploadUseCase(repository: repository)
        let result = try await useCase.uploadImage(fileURL: sourceURL, fileName: "record.heic", domain: .record)

        XCTAssertEqual(result, "image-key")
        XCTAssertEqual(repository.presignedCalls, [.init(domain: .record, fileName: "record.heic")])
        XCTAssertEqual(repository.uploads.first?.fileURL, sourceURL)
        XCTAssertNil(repository.uploads.first?.maximumPixelSize)
        XCTAssertEqual(repository.events, ["presigned", "upload"])
    }

    func testProfileNameWithoutExtensionGetsJPEGExtension() async throws {
        let repository = ImageUploadRepositorySpy()
        _ = try await ImageUploadUseCase(repository: repository).uploadImage(
            fileURL: sourceURL, fileName: "profile", domain: .profile
        )
        XCTAssertEqual(repository.presignedCalls.first?.fileName, "profile.jpg")
    }

    func testPresignedFailurePropagatesAndDoesNotUpload() async {
        let repository = ImageUploadRepositorySpy()
        repository.presignedResult = .failure(.timeout)
        await assertNetworkError(.timeout) {
            _ = try await ImageUploadUseCase(repository: repository).uploadImage(
                fileURL: sourceURL, fileName: "record.heic", domain: .record
            )
        }
        XCTAssertEqual(repository.events, ["presigned"])
        XCTAssertTrue(repository.uploads.isEmpty)
    }

    func testUploadFailurePropagatesAfterPresignedRequest() async {
        let repository = ImageUploadRepositorySpy()
        repository.uploadError = .networkUnavailable
        await assertNetworkError(.networkUnavailable) {
            _ = try await ImageUploadUseCase(repository: repository).uploadImage(
                fileURL: sourceURL, fileName: "profile.heic", domain: .profile
            )
        }
        XCTAssertEqual(repository.events, ["presigned", "upload"])
        XCTAssertEqual(repository.uploads.count, 1)
    }
}
