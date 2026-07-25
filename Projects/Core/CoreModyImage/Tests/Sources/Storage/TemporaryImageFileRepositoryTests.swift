//
//  TemporaryImageFileRepositoryTests.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 7/25/26.
//

import UIKit
import XCTest
@testable import CoreModyImage

final class TemporaryImageFileRepositoryTests: XCTestCase {
    private var directoryURL: URL!
    private var repository: TemporaryImageFileRepository!

    override func setUpWithError() throws {
        directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        repository = TemporaryImageFileRepository(
            fileManager: .default,
            directoryURL: directoryURL
        )
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directoryURL)
        repository = nil
        directoryURL = nil
    }

    func testSaveImageUsesActualHeaderForMetadataAndFileExtension() throws {
        let imageData = try XCTUnwrap(makeImage(size: CGSize(width: 80, height: 40)).pngData())

        let temporaryFile = try repository.saveImage(
            data: imageData,
            fileName: "misleading.jpg"
        )

        XCTAssertEqual(temporaryFile.contentType, "image/png")
        XCTAssertEqual(temporaryFile.fileName, "misleading.png")
        XCTAssertEqual(temporaryFile.fileURL.pathExtension, "png")
        XCTAssertEqual(try Data(contentsOf: temporaryFile.fileURL), imageData)
    }

    func testSaveImageRejectsUnknownFileData() {
        XCTAssertThrowsError(
            try repository.saveImage(
                data: Data("not-an-image".utf8),
                fileName: "image.jpg"
            )
        )
    }

    func testRemoveImageIsIdempotent() throws {
        let imageData = try XCTUnwrap(makeImage(size: CGSize(width: 10, height: 10)).pngData())
        let temporaryFile = try repository.saveImage(data: imageData, fileName: "image.png")

        try repository.removeImage(at: temporaryFile.fileURL)
        try repository.removeImage(at: temporaryFile.fileURL)

        XCTAssertFalse(FileManager.default.fileExists(atPath: temporaryFile.fileURL.path))
    }

    func testRemoveExpiredImagesKeepsRecentFile() throws {
        let imageData = try XCTUnwrap(makeImage(size: CGSize(width: 10, height: 10)).pngData())
        let expiredFile = try repository.saveImage(data: imageData, fileName: "expired.png")
        let recentFile = try repository.saveImage(data: imageData, fileName: "recent.png")
        try FileManager.default.setAttributes(
            [.modificationDate: Date().addingTimeInterval(-48 * 60 * 60)],
            ofItemAtPath: expiredFile.fileURL.path
        )

        try repository.removeExpiredImages(olderThan: 24 * 60 * 60)

        XCTAssertFalse(FileManager.default.fileExists(atPath: expiredFile.fileURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: recentFile.fileURL.path))
    }
}

private extension TemporaryImageFileRepositoryTests {
    func makeImage(size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
