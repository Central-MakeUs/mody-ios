//
//  CoreModyImageTestingTests.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreModyImageInterface
import CoreModyImageTesting
import UIKit
import XCTest

final class CoreModyImageTestingTests: XCTestCase {
    func testUploadResultAndHandlerForwarding() async throws {
        let source = URL(fileURLWithPath: "/tmp/capture.png")
        let fixed = ImageUploadUseCaseStub(result: .success("fixed-key"))
        let fixedResult = try await fixed.uploadImage(fileURL: source, fileName: "capture.png", domain: .record)
        XCTAssertEqual(fixedResult, "fixed-key")
        let dynamic = ImageUploadUseCaseStub(uploadImage: { url, name, domain in
            XCTAssertEqual(url, source)
            XCTAssertEqual(name, "capture.png")
            XCTAssertEqual(domain, .profile)
            return "dynamic-key"
        })
        let dynamicResult = try await dynamic.uploadImage(fileURL: source, fileName: "capture.png", domain: .profile)
        XCTAssertEqual(dynamicResult, "dynamic-key")
    }

    func testUploadFailureAndUnexpectedCallAreExplicit() async {
        let source = URL(fileURLWithPath: "/tmp/capture.png")
        do {
            _ = try await ImageUploadUseCaseStub(result: .failure(CocoaError(.fileReadCorruptFile)))
                .uploadImage(fileURL: source, fileName: "capture.png", domain: .record)
            XCTFail("Expected configured failure")
        } catch { XCTAssertEqual((error as? CocoaError)?.code, .fileReadCorruptFile) }
        do {
            _ = try await ImageUploadUseCaseStub().uploadImage(fileURL: source, fileName: "capture.png", domain: .record)
            XCTFail("Expected unexpected call")
        } catch { XCTAssertEqual(error as? CoreModyImageStubError, .unexpectedCall("uploadImage")) }
    }

    func testUploadDelayPropagatesCancellationBeforeCallingHandler() async {
        let stub = ImageUploadUseCaseStub(uploadImage: { _, _, _ in
            XCTFail("Cancelled upload must not invoke the handler")
            return "key"
        }, responseDelay: .seconds(60))
        let task = Task { try await stub.uploadImage(fileURL: URL(fileURLWithPath: "/tmp/photo"), fileName: "photo", domain: .record) }
        task.cancel()
        do { _ = try await task.value; XCTFail("Expected cancellation") }
        catch { XCTAssertTrue(error is CancellationError) }
    }

    func testTemporaryFileHandlersForwardArgumentsAndResults() throws {
        let file = TemporaryImageFileFixture.make()
        let data = Data([1, 2, 3])
        var removed: URL?
        var interval: TimeInterval?
        let stub = TemporaryImageFileUseCaseStub(
            saveImage: { bytes, name in
                XCTAssertEqual(bytes, data)
                XCTAssertEqual(name, "save.png")
                return file
            },
            copyImage: { url, name in
                XCTAssertEqual(url, file.fileURL)
                XCTAssertEqual(name, "copy.png")
                return file
            },
            removeImage: { removed = $0 },
            removeExpiredImages: { interval = $0 }
        )
        XCTAssertEqual(try stub.saveImage(data: data, fileName: "save.png"), file)
        XCTAssertEqual(try stub.copyImage(at: file.fileURL, fileName: "copy.png"), file)
        try stub.removeImage(at: file.fileURL)
        try stub.removeExpiredImages(olderThan: 42)
        XCTAssertEqual(removed, file.fileURL)
        XCTAssertEqual(interval, 42)
    }

    func testUnconfiguredTemporaryFileMethodsThrow() {
        let stub = TemporaryImageFileUseCaseStub()
        let url = URL(fileURLWithPath: "/tmp/photo")
        let calls: [(String, () throws -> Void)] = [
            ("saveImage", { _ = try stub.saveImage(data: Data(), fileName: "photo") }),
            ("copyImage", { _ = try stub.copyImage(at: url, fileName: "photo") }),
            ("removeImage", { try stub.removeImage(at: url) }),
            ("removeExpiredImages", { try stub.removeExpiredImages(olderThan: 10) })
        ]
        for (name, call) in calls {
            XCTAssertThrowsError(try call()) { error in
                XCTAssertEqual(error as? CoreModyImageStubError, .unexpectedCall(name))
            }
        }
    }

    func testTemporaryFileHandlerErrorsPropagate() {
        let stub = TemporaryImageFileUseCaseStub(
            saveImage: { _, _ in throw CocoaError(.fileReadCorruptFile) },
            copyImage: { _, _ in throw CocoaError(.fileReadCorruptFile) },
            removeImage: { _ in throw CocoaError(.fileReadCorruptFile) },
            removeExpiredImages: { _ in throw CocoaError(.fileReadCorruptFile) }
        )
        let url = URL(fileURLWithPath: "/tmp/photo")
        let calls: [() throws -> Void] = [
            { _ = try stub.saveImage(data: Data(), fileName: "photo") },
            { _ = try stub.copyImage(at: url, fileName: "photo") },
            { try stub.removeImage(at: url) },
            { try stub.removeExpiredImages(olderThan: 10) }
        ]
        for call in calls {
            XCTAssertThrowsError(try call()) { error in
                XCTAssertEqual((error as? CocoaError)?.code, .fileReadCorruptFile)
            }
        }
    }

    func testMetadataOnlyStubReturnsInputNamesAndURLsWithoutWritingFiles() throws {
        let name = "\(UUID().uuidString).png"
        let stub = TemporaryImageFileUseCaseStub.metadataOnly(contentType: "image/png")
        let saved = try stub.saveImage(data: Data([1]), fileName: name)
        XCTAssertEqual(saved.fileName, name)
        XCTAssertEqual(saved.contentType, "image/png")
        XCTAssertEqual(saved.fileURL, URL(fileURLWithPath: "/tmp").appendingPathComponent(name))
        XCTAssertFalse(FileManager.default.fileExists(atPath: saved.fileURL.path))
        let source = URL(fileURLWithPath: "/tmp/source.png")
        let copy = try stub.copyImage(at: source, fileName: "copy.png")
        XCTAssertEqual(copy, TemporaryImageFile(fileURL: source, fileName: "copy.png", contentType: "image/png"))
        try stub.removeImage(at: saved.fileURL)
        try stub.removeExpiredImages(olderThan: 0)
    }

    func testFixtureHonorsExplicitURLAndMetadata() {
        let url = URL(fileURLWithPath: "/tmp/fixture.heic")
        XCTAssertEqual(TemporaryImageFileFixture.make(fileURL: url, fileName: "fixture.heic", contentType: "image/heic"),
                       TemporaryImageFile(fileURL: url, fileName: "fixture.heic", contentType: "image/heic"))
    }

    func testRemoteImageHandlersReceiveOriginalRequest() async throws {
        let image = ImageFixture.make()
        let request = RemoteImageRequest(url: URL(string: "https://image.invalid/test")!, variantIdentifier: "record", maximumPixelSize: 80)
        let stub = RemoteImageLoaderStub(cachedImage: { input in
            XCTAssertEqual(input, request)
            return image
        }, loadImage: { input in
            XCTAssertEqual(input, request)
            return image
        })
        XCTAssertTrue(stub.cachedImage(for: request) === image)
        let loaded = try await stub.loadImage(with: request)
        XCTAssertTrue(loaded === image)
    }

    func testRemoteImageDefaultsAndConfiguredError() async {
        let request = RemoteImageRequest(url: URL(string: "https://image.invalid/test")!, variantIdentifier: "a", maximumPixelSize: 10)
        let stub = RemoteImageLoaderStub()
        XCTAssertNil(stub.cachedImage(for: request))
        do { _ = try await stub.loadImage(with: request); XCTFail("Expected unexpected call") }
        catch { XCTAssertEqual(error as? CoreModyImageStubError, .unexpectedCall("loadImage")) }
        let failing = RemoteImageLoaderStub(loadImage: { _ in throw URLError(.timedOut) })
        do { _ = try await failing.loadImage(with: request); XCTFail("Expected timeout") }
        catch { XCTAssertEqual((error as? URLError)?.code, .timedOut) }
    }

    func testRemoteImageDelayPropagatesCancellation() async {
        let stub = RemoteImageLoaderStub(loadImage: { _ in
            XCTFail("Cancelled load must not invoke handler")
            return UIImage()
        }, responseDelay: .seconds(60))
        let request = RemoteImageRequest(url: URL(string: "https://image.invalid/test")!, variantIdentifier: "cancel", maximumPixelSize: 10)
        let task = Task { try await stub.loadImage(with: request) }
        task.cancel()
        do { _ = try await task.value; XCTFail("Expected cancellation") }
        catch { XCTAssertTrue(error is CancellationError) }
    }
}
