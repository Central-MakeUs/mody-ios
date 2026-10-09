//
//  NormalizedCropProcessorTests.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreModyImageInterface
import UIKit
import XCTest
@testable import CoreModyImage

final class NormalizedCropProcessorTests: XCTestCase {
    func testNormalizedCropUsesRequestedSourcePixelsAndOutputSize() throws {
        let crop = try XCTUnwrap(NormalizedImageCropInfo(x: 0.5, y: 0, width: 0.5, height: 1))
        let processor = NormalizedCropProcessor(normalizedCrop: crop, outputPixelSize: CGSize(width: 20, height: 20))
        let output = try XCTUnwrap(processor.process(ImageFixture.make()))
        let cgImage = try XCTUnwrap(output.cgImage)
        XCTAssertEqual(cgImage.width, 20)
        XCTAssertEqual(cgImage.height, 20)
        XCTAssertEqual(output.imageOrientation, .up)
        let pixel = try centerPixel(of: output)
        XCTAssertLessThan(pixel[0], 5)
        XCTAssertGreaterThan(pixel[2], 250)
    }

    func testVerticalCropUsesYAndHeightIndependentlyOfXAndWidth() throws {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let source = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 80), format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 40, height: 40))
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0, y: 40, width: 40, height: 40))
        }
        let crop = try XCTUnwrap(NormalizedImageCropInfo(x: 0, y: 0.5, width: 1, height: 0.5))
        let output = try XCTUnwrap(NormalizedCropProcessor(
            normalizedCrop: crop, outputPixelSize: CGSize(width: 20, height: 20)
        ).process(source))
        let pixel = try centerPixel(of: output)
        XCTAssertLessThan(pixel[0], 5)
        XCTAssertGreaterThan(pixel[2], 250)
    }

    func testNoCropStillAspectFillsAndUpscales() throws {
        let output = try XCTUnwrap(NormalizedCropProcessor(
            normalizedCrop: nil, outputPixelSize: CGSize(width: 160, height: 80)
        ).process(ImageFixture.make()))
        XCTAssertEqual(output.cgImage?.width, 160)
        XCTAssertEqual(output.cgImage?.height, 80)
    }

    func testFullImageCropAndFractionalCropProduceBoundedOutput() throws {
        for crop in [
            NormalizedImageCropInfo(x: 0, y: 0, width: 1, height: 1),
            NormalizedImageCropInfo(x: 0.501, y: 0.013, width: 0.4, height: 0.7)
        ] {
            let output = try XCTUnwrap(NormalizedCropProcessor(
                normalizedCrop: crop, outputPixelSize: CGSize(width: 15, height: 30)
            ).process(ImageFixture.make()))
            XCTAssertEqual(output.cgImage?.width, 15)
            XCTAssertEqual(output.cgImage?.height, 30)
        }
    }

    func testMissingCGImageFallsBackWithoutCrashing() {
        let crop = NormalizedImageCropInfo(x: 0, y: 0, width: 1, height: 1)
        let processor = NormalizedCropProcessor(normalizedCrop: crop, outputPixelSize: CGSize(width: 10, height: 10))
        XCTAssertNil(processor.process(UIImage()))
    }

    func testIdentifierAndHashDistinguishCropAndOutputSize() throws {
        let crop = try XCTUnwrap(NormalizedImageCropInfo(x: 0.1234567, y: 0.2, width: 0.5, height: 0.6))
        let a = NormalizedCropProcessor(normalizedCrop: crop, outputPixelSize: CGSize(width: 20, height: 30))
        let same = NormalizedCropProcessor(normalizedCrop: crop, outputPixelSize: CGSize(width: 20, height: 30))
        let noCrop = NormalizedCropProcessor(normalizedCrop: nil, outputPixelSize: CGSize(width: 20, height: 30))
        let resized = NormalizedCropProcessor(normalizedCrop: crop, outputPixelSize: CGSize(width: 21, height: 30))
        XCTAssertEqual(a.identifier, "com.mody.core-image.normalized-crop|v1|0.123457,0.200000,0.500000,0.600000|20x30")
        XCTAssertEqual(noCrop.identifier, "com.mody.core-image.normalized-crop|v1|none|20x30")
        XCTAssertEqual(a, same)
        XCTAssertEqual(Set([a, same, noCrop, resized]).count, 3)
    }

    private func centerPixel(of image: UIImage) throws -> [UInt8] {
        let cgImage = try XCTUnwrap(image.cgImage)
        let pixel = try XCTUnwrap(cgImage.cropping(to: CGRect(x: cgImage.width / 2, y: cgImage.height / 2, width: 1, height: 1)))
        var bytes = [UInt8](repeating: 0, count: 4)
        try bytes.withUnsafeMutableBytes { buffer in
            let context = try XCTUnwrap(CGContext(
                data: buffer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ))
            context.draw(pixel, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        return bytes
    }
}
