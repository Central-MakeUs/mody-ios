//
//  ImageUploadUseCaseTests.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 7/26/26.
//

import CoreModyImageInterface
import Foundation
import XCTest
@testable import CoreModyImage

final class ImageUploadUseCaseTests: XCTestCase {
    func testProfileUploadAppliesInternal640PixelPolicy() async throws {
        let repository = ImageUploadRepositoryMock()
        let useCase = ImageUploadUseCase(repository: repository)

        _ = try await useCase.uploadImage(
            fileURL: URL(fileURLWithPath: "/tmp/profile.heic"),
            fileName: "profile.heic",
            domain: .profile
        )

        XCTAssertEqual(repository.presignedFileName, "profile.jpg")
        XCTAssertEqual(repository.maximumPixelSize, 640)
    }

    func testRecordUploadKeepsOriginalUploadPolicy() async throws {
        let repository = ImageUploadRepositoryMock()
        let useCase = ImageUploadUseCase(repository: repository)

        _ = try await useCase.uploadImage(
            fileURL: URL(fileURLWithPath: "/tmp/record.heic"),
            fileName: "record.heic",
            domain: .record
        )

        XCTAssertEqual(repository.presignedFileName, "record.heic")
        XCTAssertNil(repository.maximumPixelSize)
    }
}

private final class ImageUploadRepositoryMock: ImageUploadRepositoryProtocol {
    private(set) var presignedFileName: String?
    private(set) var maximumPixelSize: Int?

    func postPresignedURL(
        domain: ImageUploadDomain,
        fileName: String
    ) async throws -> PresignedImageUpload {
        presignedFileName = fileName
        return PresignedImageUpload(
            url: URL(string: "https://example.com/upload")!,
            imageKey: "image-key"
        )
    }

    func putImage(
        fileURL: URL,
        to url: URL,
        maximumPixelSize: Int?
    ) async throws {
        self.maximumPixelSize = maximumPixelSize
    }
}
