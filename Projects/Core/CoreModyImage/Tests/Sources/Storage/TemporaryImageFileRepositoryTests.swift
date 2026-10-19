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

    func testSaveRejectsEmptyDataWithoutCreatingDirectory() {
        XCTAssertThrowsError(try repository.saveImage(data: Data(), fileName: "empty.png")) { error in
            XCTAssertEqual((error as? CocoaError)?.code, .fileReadCorruptFile)
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: directoryURL.path))
    }

    func testDefaultRepositoryUsesModyUploadsAndRemovesOnlySavedFile() throws {
        let repository = TemporaryImageFileRepository()
        let data = try XCTUnwrap(ImageFixture.make().pngData())
        let file = try repository.saveImage(data: data, fileName: "default-test.png")
        defer { try? repository.removeImage(at: file.fileURL) }
        XCTAssertEqual(file.fileURL.deletingLastPathComponent().lastPathComponent, "ModyUploads")
        XCTAssertEqual(file.fileName, "default-test.png")
        XCTAssertEqual(try Data(contentsOf: file.fileURL), data)
        try repository.removeImage(at: file.fileURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.fileURL.path))
    }

    func testJPEGHeaderDeterminesMetadataAndTrimsPathFromUploadName() throws {
        let data = try XCTUnwrap(ImageFixture.make().jpegData(compressionQuality: 0.9))
        let file = try repository.saveImage(data: data, fileName: "  /folder/my.photo.png \n")
        XCTAssertEqual(file.fileName, "my.photo.jpeg")
        XCTAssertEqual(file.contentType, "image/jpeg")
        XCTAssertEqual(file.fileURL.pathExtension, "jpeg")
        XCTAssertEqual(try Data(contentsOf: file.fileURL), data)
    }

    func testSameNameSavesToDistinctLocalURLs() throws {
        let data = try XCTUnwrap(ImageFixture.make().pngData())
        let first = try repository.saveImage(data: data, fileName: "same.png")
        let second = try repository.saveImage(data: data, fileName: "same.png")
        XCTAssertNotEqual(first.fileURL, second.fileURL)
        XCTAssertEqual(first.fileName, second.fileName)
        XCTAssertEqual(try Data(contentsOf: first.fileURL), data)
        XCTAssertEqual(try Data(contentsOf: second.fileURL), data)
    }

    func testCopyPreservesSourceAndBytesWithHeaderBasedName() throws {
        let source = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let data = try XCTUnwrap(ImageFixture.make().pngData())
        try data.write(to: source)
        defer { try? FileManager.default.removeItem(at: source) }
        let file = try repository.copyImage(at: source, fileName: "  renamed.jpg  ")
        XCTAssertNotEqual(file.fileURL, source)
        XCTAssertEqual(file.fileName, "renamed.png")
        XCTAssertEqual(file.contentType, "image/png")
        XCTAssertEqual(try Data(contentsOf: source), data)
        XCTAssertEqual(try Data(contentsOf: file.fileURL), data)
    }

    func testCopyRejectsMissingAndCorruptSources() throws {
        let source = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        XCTAssertThrowsError(try repository.copyImage(at: source, fileName: "missing.jpg")) { error in
            XCTAssertEqual((error as? CocoaError)?.code, .fileReadCorruptFile)
        }
        try Data("corrupt".utf8).write(to: source)
        defer { try? FileManager.default.removeItem(at: source) }
        XCTAssertThrowsError(try repository.copyImage(at: source, fileName: "image.jpg"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: directoryURL.path))
    }

    func testSaveFailsWhenDestinationIsARegularFile() throws {
        try Data().write(to: directoryURL)
        let data = try XCTUnwrap(ImageFixture.make().pngData())
        XCTAssertThrowsError(try repository.saveImage(data: data, fileName: "image.png"))
    }

    func testCleanupMissingDirectoryIsNoOp() throws {
        try repository.removeExpiredImages(olderThan: 0)
        XCTAssertFalse(FileManager.default.fileExists(atPath: directoryURL.path))
    }

    func testCleanupSkipsHiddenFilesAndDirectories() throws {
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let hidden = directoryURL.appendingPathComponent(".hidden.png")
        let nested = directoryURL.appendingPathComponent("nested", isDirectory: true)
        try Data().write(to: hidden)
        try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: true)
        let old = Date().addingTimeInterval(-3600)
        for url in [hidden, nested] {
            try FileManager.default.setAttributes([.modificationDate: old], ofItemAtPath: url.path)
        }
        try repository.removeExpiredImages(olderThan: 60)
        XCTAssertTrue(FileManager.default.fileExists(atPath: hidden.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: nested.path))
    }

    func testSaveImageUsesActualHeaderForMetadataAndFileExtension() throws {
        let imageData = try XCTUnwrap(ImageFixture.make(size: CGSize(width: 80, height: 40)).pngData())

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
        let imageData = try XCTUnwrap(ImageFixture.make(size: CGSize(width: 10, height: 10)).pngData())
        let temporaryFile = try repository.saveImage(data: imageData, fileName: "image.png")

        try repository.removeImage(at: temporaryFile.fileURL)
        try repository.removeImage(at: temporaryFile.fileURL)

        XCTAssertFalse(FileManager.default.fileExists(atPath: temporaryFile.fileURL.path))
    }

    func testRemoveExpiredImagesKeepsRecentFile() throws {
        let imageData = try XCTUnwrap(ImageFixture.make(size: CGSize(width: 10, height: 10)).pngData())
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
