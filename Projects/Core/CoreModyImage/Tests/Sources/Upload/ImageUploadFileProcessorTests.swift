//
//  ImageUploadFileProcessorTests.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 7/26/26.
//

import CommonDomain
import ImageIO
import UIKit
import UniformTypeIdentifiers
import XCTest
@testable import CoreModyImage

final class ImageUploadFileProcessorTests: XCTestCase {
    func testRejectsNonPositiveLimitMissingFileAndCorruptData() throws {
        let source = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        for limit in [0, -1, 640] {
            XCTAssertThrowsError(try ImageUploadFileProcessor().makeDownsampledJPEG(from: source, maximumPixelSize: limit)) { error in
                XCTAssertEqual(error as? NetworkError, .invalidResponse)
            }
        }
        try Data("corrupt".utf8).write(to: source)
        defer { try? FileManager.default.removeItem(at: source) }
        XCTAssertThrowsError(try ImageUploadFileProcessor().makeDownsampledJPEG(from: source, maximumPixelSize: 640)) { error in
            XCTAssertEqual(error as? NetworkError, .invalidResponse)
        }
    }

    func testSmallImageIsNotUpscaledAndSourceRemainsIntact() throws {
        let source = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let data = try XCTUnwrap(ImageFixture.make(size: CGSize(width: 20, height: 40)).pngData())
        try data.write(to: source)
        defer { try? FileManager.default.removeItem(at: source) }
        let output = try ImageUploadFileProcessor().makeDownsampledJPEG(from: source, maximumPixelSize: 640)
        defer { try? FileManager.default.removeItem(at: output) }
        let image = try XCTUnwrap(UIImage(contentsOfFile: output.path)?.cgImage)
        XCTAssertEqual(image.width, 20)
        XCTAssertEqual(image.height, 40)
        XCTAssertEqual(output.pathExtension, "jpg")
        XCTAssertNotEqual(source, output)
        XCTAssertEqual(try Data(contentsOf: source), data)
    }

    func testDownsampledJPEGPreservesRatioWithinMaximumPixelSize() throws {
        let sourceURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("png")
        let sourceImage = ImageFixture.make(size: CGSize(width: 1200, height: 800))
        try XCTUnwrap(sourceImage.pngData()).write(to: sourceURL)
        defer { try? FileManager.default.removeItem(at: sourceURL) }

        let outputURL = try ImageUploadFileProcessor().makeDownsampledJPEG(
            from: sourceURL,
            maximumPixelSize: 640
        )
        defer { try? FileManager.default.removeItem(at: outputURL) }

        let imageSource = try XCTUnwrap(
            CGImageSourceCreateWithURL(outputURL as CFURL, nil)
        )
        let outputImage = try XCTUnwrap(
            CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        )

        XCTAssertEqual(
            CGImageSourceGetType(imageSource) as String?,
            UTType.jpeg.identifier
        )
        XCTAssertLessThanOrEqual(max(outputImage.width, outputImage.height), 640)
        XCTAssertEqual(outputImage.width, 640)
        XCTAssertEqual(outputImage.height, 427)
    }
}
