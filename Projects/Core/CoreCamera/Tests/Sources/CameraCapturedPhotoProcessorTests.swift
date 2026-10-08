//  CameraCapturedPhotoProcessorTests.swift
//  CoreCameraTests
//
//  Created by 김동준 on 10/9/26.
//

import UIKit
import XCTest

@testable import CoreCamera

final class CameraCapturedPhotoProcessorTests: XCTestCase {
    func testDataInputSavesOriginalNameAndCreatesBoundedPreview() throws {
        let spy = CameraTemporaryImageFileSpy()
        let data = try XCTUnwrap(CameraImageFixture.image().pngData())
        let result = try makeSUT(spy).makeCapturedPhoto(data: data, fileName: "원본.png")
        XCTAssertEqual(spy.calls, [.save(data, "원본.png")])
        XCTAssertEqual(result.originalFile.fileName, "원본.png")
        XCTAssertEqual(try Data(contentsOf: result.originalFile.fileURL), data)
        XCTAssertEqual(result.previewImage.size, CGSize(width: 20, height: 10))
    }

    func testLibraryInputCopiesFileBeforeProviderFileExpires() throws {
        let source = CameraTemporaryImageFileSpy()
        let data = try XCTUnwrap(CameraImageFixture.image().pngData())
        let input = try source.saveImage(data: data, fileName: "provider.png")
        let spy = CameraTemporaryImageFileSpy()
        let result = try makeSUT(spy).makeCapturedPhoto(fileURL: input.fileURL, fileName: "original.png")
        try source.removeImage(at: input.fileURL)
        XCTAssertEqual(spy.calls, [.copy(input.fileURL, "original.png")])
        XCTAssertNotEqual(input.fileURL, result.originalFile.fileURL)
        XCTAssertEqual(try Data(contentsOf: result.originalFile.fileURL), data)
    }

    func testSaveAndCopyErrorsPropagateWithoutCleanupOfUnownedInput() {
        let error = CocoaError(.fileWriteNoPermission)
        let spy = CameraTemporaryImageFileSpy()
        spy.saveError = error
        spy.copyError = error
        let sut = makeSUT(spy)
        XCTAssertThrowsError(try sut.makeCapturedPhoto(data: Data(), fileName: "bad")) {
            XCTAssertEqual($0 as NSError, error as NSError)
        }
        let url = URL(fileURLWithPath: "/provider/image")
        XCTAssertThrowsError(try sut.makeCapturedPhoto(fileURL: url, fileName: "bad")) {
            XCTAssertEqual($0 as NSError, error as NSError)
        }
        XCTAssertEqual(spy.calls, [.save(Data(), "bad"), .copy(url, "bad")])
    }

    func testInvalidSavedImageIsRemovedAndReportsCorruptFileEvenIfRemovalFails() {
        for removalFails in [false, true] {
            let spy = CameraTemporaryImageFileSpy()
            if removalFails { spy.removeError = CocoaError(.fileWriteNoPermission) }
            XCTAssertThrowsError(try makeSUT(spy).makeCapturedPhoto(data: Data([1, 2, 3]), fileName: "bad")) {
                XCTAssertEqual(($0 as NSError).code, CocoaError.fileReadCorruptFile.rawValue)
            }
            XCTAssertEqual(spy.calls.count, 2)
            guard case .remove = spy.calls.last else { return XCTFail("Owned invalid file must be removed") }
        }
    }

    func testInvalidCopiedImageIsRemoved() throws {
        let source = CameraTemporaryImageFileSpy()
        let input = try source.saveImage(data: Data(), fileName: "bad")
        let spy = CameraTemporaryImageFileSpy()
        XCTAssertThrowsError(try makeSUT(spy).makeCapturedPhoto(fileURL: input.fileURL, fileName: "bad"))
        XCTAssertEqual(spy.calls.count, 2)
        guard case .remove(let url) = spy.calls.last else { return XCTFail("Missing cleanup") }
        XCTAssertNotEqual(url, input.fileURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: input.fileURL.path))
    }

    func testInvalidPreviewLimitRemovesSavedFile() throws {
        for limit in [0, -1] {
            let spy = CameraTemporaryImageFileSpy()
            let sut = CameraCapturedPhotoProcessor(temporaryImageFileUseCase: spy, previewMaxPixelSize: limit)
            XCTAssertThrowsError(
                try sut.makeCapturedPhoto(data: XCTUnwrap(CameraImageFixture.image().pngData()), fileName: "photo"))
            XCTAssertEqual(spy.calls.count, 2)
        }
    }

    func testRemoveForwardsOnlyOwnedFileAndIgnoresRemovalError() {
        let spy = CameraTemporaryImageFileSpy()
        spy.removeError = CocoaError(.fileWriteNoPermission)
        let photo = CameraImageFixture.photo()
        makeSUT(spy).removeCapturedPhoto(photo)
        XCTAssertEqual(spy.calls, [.remove(photo.originalFile.fileURL)])
    }

    func testEveryRotationPreservesFilenameSavesJPEGThenRemovesOriginal() throws {
        for rotation: CameraImageRotation in [.zero, .ninety, .oneEighty, .twoSeventy] {
            let spy = CameraTemporaryImageFileSpy()
            let sut = makeSUT(spy)
            let photo = try sut.makeCapturedPhoto(
                data: XCTUnwrap(CameraImageFixture.image().pngData()), fileName: "original.png")
            let output = try sut.makeRotatedFile(from: photo, rotation: rotation)
            let data = try Data(contentsOf: output.fileURL)
            let image = try XCTUnwrap(UIImage(data: data))
            XCTAssertEqual(Array(data.prefix(2)), [0xff, 0xd8])
            XCTAssertEqual(output.fileName, "original.png")
            XCTAssertEqual(
                image.size,
                rotation == .ninety || rotation == .twoSeventy
                    ? CGSize(width: 40, height: 80) : CGSize(width: 80, height: 40))
            XCTAssertEqual(spy.calls.count, 3)
            XCTAssertEqual(spy.calls.last, .remove(photo.originalFile.fileURL))
            XCTAssertFalse(FileManager.default.fileExists(atPath: photo.originalFile.fileURL.path))
        }
    }

    func testRotationUnreadableOriginalFailsWithoutSavingOrRemoving() {
        let spy = CameraTemporaryImageFileSpy()
        XCTAssertThrowsError(
            try makeSUT(spy).makeRotatedFile(
                from: CameraImageFixture.photo(fileName: UUID().uuidString), rotation: .ninety)
        ) {
            XCTAssertEqual(($0 as NSError).code, CocoaError.fileReadCorruptFile.rawValue)
        }
        XCTAssertTrue(spy.calls.isEmpty)
    }

    func testRotationSaveFailureRetainsOriginalForRetry() throws {
        let spy = CameraTemporaryImageFileSpy()
        let sut = makeSUT(spy)
        let photo = try sut.makeCapturedPhoto(data: XCTUnwrap(CameraImageFixture.image().pngData()), fileName: "photo")
        let error = CocoaError(.fileWriteOutOfSpace)
        spy.saveError = error
        XCTAssertThrowsError(try sut.makeRotatedFile(from: photo, rotation: .ninety)) {
            XCTAssertEqual($0 as NSError, error as NSError)
        }
        XCTAssertEqual(spy.calls.count, 2)
        XCTAssertTrue(FileManager.default.fileExists(atPath: photo.originalFile.fileURL.path))
    }

    func testRotationCleanupFailureStillReturnsNewFile() throws {
        let spy = CameraTemporaryImageFileSpy()
        let sut = makeSUT(spy)
        let photo = try sut.makeCapturedPhoto(data: XCTUnwrap(CameraImageFixture.image().pngData()), fileName: "photo")
        spy.removeError = CocoaError(.fileWriteNoPermission)
        let output = try sut.makeRotatedFile(from: photo, rotation: .ninety)
        XCTAssertNotEqual(output.fileURL, photo.originalFile.fileURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: output.fileURL.path))
    }

    func testJPEGEncodingFailureDoesNotSaveOrRemoveOriginal() throws {
        let spy = CameraTemporaryImageFileSpy()
        let sut = CameraCapturedPhotoProcessor(
            temporaryImageFileUseCase: spy, previewMaxPixelSize: 20, encodeJPEG: { _ in nil })
        let photo = try sut.makeCapturedPhoto(data: XCTUnwrap(CameraImageFixture.image().pngData()), fileName: "photo")
        XCTAssertThrowsError(try sut.makeRotatedFile(from: photo, rotation: .ninety)) {
            XCTAssertEqual(($0 as NSError).code, CocoaError.fileWriteUnknown.rawValue)
        }
        XCTAssertEqual(spy.calls.count, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: photo.originalFile.fileURL.path))
    }

    private func makeSUT(_ spy: CameraTemporaryImageFileSpy) -> CameraCapturedPhotoProcessor {
        CameraCapturedPhotoProcessor(temporaryImageFileUseCase: spy, previewMaxPixelSize: 20)
    }
}
