//
//  ImageUploadFileProcessorTests.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 7/26/26.
//

import ImageIO
import UIKit
import UniformTypeIdentifiers
import XCTest
@testable import CoreModyImage

final class ImageUploadFileProcessorTests: XCTestCase {
    func testDownsampledJPEGPreservesRatioWithinMaximumPixelSize() throws {
        let sourceURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("png")
        let sourceImage = makeImage(size: CGSize(width: 1200, height: 800))
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

private extension ImageUploadFileProcessorTests {
    func makeImage(size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
