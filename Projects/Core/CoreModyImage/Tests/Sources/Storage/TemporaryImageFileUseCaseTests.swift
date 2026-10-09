//
//  TemporaryImageFileUseCaseTests.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 10/9/26.
//

import Foundation
import XCTest
@testable import CoreModyImage

final class TemporaryImageFileUseCaseTests: XCTestCase {
    func testSaveForwardsBytesAndNameAndReturnsRepositoryFile() throws {
        let spy = TemporaryImageFileRepositorySpy()
        let data = Data([1, 2, 3])
        let result = try TemporaryImageFileUseCase(repository: spy).saveImage(data: data, fileName: "capture.heic")
        XCTAssertEqual(result, spy.file)
        XCTAssertEqual(spy.savedData, data)
        XCTAssertEqual(spy.fileNames, ["capture.heic"])
    }

    func testCopyForwardsSourceAndNameAndReturnsRepositoryFile() throws {
        let spy = TemporaryImageFileRepositorySpy()
        let source = URL(fileURLWithPath: "/tmp/source.png")
        let result = try TemporaryImageFileUseCase(repository: spy).copyImage(at: source, fileName: "renamed.png")
        XCTAssertEqual(result, spy.file)
        XCTAssertEqual(spy.copiedURL, source)
        XCTAssertEqual(spy.fileNames, ["renamed.png"])
    }

    func testRemovalAndExpirationForwardExactArguments() throws {
        let spy = TemporaryImageFileRepositorySpy()
        let useCase = TemporaryImageFileUseCase(repository: spy)
        try useCase.removeImage(at: spy.file.fileURL)
        try useCase.removeExpiredImages(olderThan: 123)
        XCTAssertEqual(spy.removedURLs, [spy.file.fileURL])
        XCTAssertEqual(spy.expirationIntervals, [123])
    }

    func testEveryRepositoryErrorPropagates() {
        let spy = TemporaryImageFileRepositorySpy()
        spy.error = CocoaError(.fileWriteNoPermission)
        let useCase = TemporaryImageFileUseCase(repository: spy)
        let operations: [() throws -> Void] = [
            { _ = try useCase.saveImage(data: Data(), fileName: "image.jpg") },
            { _ = try useCase.copyImage(at: spy.file.fileURL, fileName: "image.jpg") },
            { try useCase.removeImage(at: spy.file.fileURL) },
            { try useCase.removeExpiredImages(olderThan: 10) }
        ]
        for operation in operations {
            XCTAssertThrowsError(try operation()) { error in
                XCTAssertEqual((error as? CocoaError)?.code, .fileWriteNoPermission)
            }
        }
    }
}
