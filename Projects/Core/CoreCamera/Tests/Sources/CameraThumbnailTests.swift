//  CameraThumbnailTests.swift
//  CoreCameraTests
//
//  Created by 김동준 on 10/9/26.
//

import ImageIO
import UIKit
import XCTest

@testable import CoreCamera

final class CameraThumbnailTests: XCTestCase {
    func testMissingCorruptAndEmptyFilesReturnNil() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: url) }
        let sut = CameraImageThumbnailGenerator()
        XCTAssertNil(sut.makeThumbnail(fileURL: url, maxPixelSize: 100))
        for data in [Data(), Data([1, 2, 3])] {
            try data.write(to: url)
            XCTAssertNil(sut.makeThumbnail(fileURL: url, maxPixelSize: 100))
        }
    }

    func testInvalidLimitsReturnNilAndSmallImageIsNotUpscaled() throws {
        let spy = CameraTemporaryImageFileSpy()
        let file = try spy.saveImage(data: XCTUnwrap(CameraImageFixture.image().pngData()), fileName: "photo")
        let sut = CameraImageThumbnailGenerator()
        for size in [0, -1] { XCTAssertNil(sut.makeThumbnail(fileURL: file.fileURL, maxPixelSize: size)) }
        let image = try XCTUnwrap(sut.makeThumbnail(fileURL: file.fileURL, maxPixelSize: 1000))
        XCTAssertEqual(image.size, CGSize(width: 80, height: 40))
    }

    func testThumbnailAppliesEXIFOrientationBeforeReturningUpImage() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")
        defer { try? FileManager.default.removeItem(at: url) }
        let destination = try XCTUnwrap(
            CGImageDestinationCreateWithURL(url as CFURL, "public.jpeg" as CFString, 1, nil))
        CGImageDestinationAddImage(
            destination, try XCTUnwrap(CameraImageFixture.image().cgImage),
            [kCGImagePropertyOrientation: 6] as CFDictionary)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        let result = try XCTUnwrap(CameraImageThumbnailGenerator().makeThumbnail(fileURL: url, maxPixelSize: 20))
        XCTAssertEqual(result.size, CGSize(width: 10, height: 20))
        XCTAssertEqual(result.imageOrientation, .up)
        XCTAssertEqual(result.scale, 1)
    }
}
