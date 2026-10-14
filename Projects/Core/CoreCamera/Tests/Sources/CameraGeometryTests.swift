//  CameraGeometryTests.swift
//  CoreCameraTests
//
//  Created by 김동준 on 10/9/26.
//

import UIKit
import XCTest

@testable import CoreCamera

final class CameraGeometryTests: XCTestCase {
    func testAspectFillAndFitCenterLandscapeAndPortraitImages() throws {
        let cases: [(CGSize, CameraImageDisplayMode, CGRect)] = [
            (CGSize(width: 200, height: 100), .aspectFill, CGRect(x: -50, y: 0, width: 200, height: 100)),
            (CGSize(width: 200, height: 100), .aspectFit, CGRect(x: 0, y: 25, width: 100, height: 50)),
            (CGSize(width: 100, height: 200), .aspectFill, CGRect(x: 0, y: -50, width: 100, height: 200)),
            (CGSize(width: 100, height: 200), .aspectFit, CGRect(x: 25, y: 0, width: 50, height: 100)),
        ]
        for (size, mode, expected) in cases {
            let layout = try XCTUnwrap(
                CameraDisplayedImageLayout.make(
                    imageSize: size, containerSize: CGSize(width: 100, height: 100), displayMode: mode))
            XCTAssertEqual(layout.originalImageBounds, CGRect(origin: .zero, size: size))
            XCTAssertEqual(layout.displayedImageFrame, expected)
        }
    }

    func testInvalidImageOrContainerDimensionsReturnNilForBothModes() {
        for invalid: CGFloat in [0, -1, .infinity, -.infinity, .nan] {
            for mode: CameraImageDisplayMode in [.aspectFill, .aspectFit] {
                for size in [CGSize(width: invalid, height: 100), CGSize(width: 100, height: invalid)] {
                    XCTAssertNil(
                        CameraDisplayedImageLayout.make(
                            imageSize: size, containerSize: CGSize(width: 100, height: 100), displayMode: mode))
                    XCTAssertNil(
                        CameraDisplayedImageLayout.make(
                            imageSize: CGSize(width: 100, height: 100), containerSize: size, displayMode: mode))
                }
            }
        }
    }

    func testCropIntersectsPartialSelectionAndRejectsOutsideOrEmptySelection() throws {
        let image = CameraImageFixture.image(size: CGSize(width: 100, height: 100))
        let sut = CameraImageCropper()
        let output = try XCTUnwrap(
            sut.crop(
                image: image, selectionFrame: CGRect(x: -20, y: -10, width: 70, height: 60), containerSize: image.size))
        XCTAssertEqual(output.normalizedSelectionFrame, CGRect(x: 0, y: 0, width: 0.5, height: 0.5))
        XCTAssertEqual(output.croppedImage.size, CGSize(width: 50, height: 50))
        for selection in [
            CGRect.zero, CGRect(x: 100, y: 0, width: 30, height: 30), CGRect(x: 0, y: 101, width: 20, height: 20),
        ] {
            XCTAssertNil(sut.crop(image: image, selectionFrame: selection, containerSize: image.size))
        }
        XCTAssertNil(
            sut.crop(image: UIImage(), selectionFrame: CGRect(x: 0, y: 0, width: 10, height: 10), containerSize: .zero))
    }

    func testAspectFillCropMapsVisibleCenterAndUsesPointCoordinatesForRetinaImages() throws {
        let image = CameraImageFixture.image(size: CGSize(width: 200, height: 100), scale: 3)
        let output = try XCTUnwrap(
            CameraImageCropper().crop(
                image: image, selectionFrame: CGRect(x: 0, y: 0, width: 100, height: 100),
                containerSize: CGSize(width: 100, height: 100)))
        XCTAssertEqual(output.normalizedSelectionFrame, CGRect(x: 0.25, y: 0, width: 0.5, height: 1))
        XCTAssertEqual(output.croppedImage.scale, 1)
        XCTAssertEqual(output.croppedImage.cgImage?.width, 100)
    }

    func testAspectFitSelectionEntirelyInsideLetterboxReturnsNil() {
        XCTAssertNil(
            CameraImageCropper().crop(
                image: CameraImageFixture.image(), selectionFrame: CGRect(x: 0, y: 0, width: 80, height: 10),
                containerSize: CGSize(width: 80, height: 80), displayMode: .aspectFit))
    }

    func testRotationArithmeticWrapsBothDirectionsAndMultipleTurns() {
        for rotation: CameraImageRotation in [.zero, .ninety, .oneEighty, .twoSeventy] {
            for turns in -12...12 {
                let expected = ((rotation.rawValue / 90 + turns) % 4 + 4) % 4 * 90
                XCTAssertEqual(rotation.adding(clockwise: turns * 90).rawValue, expected)
            }
            XCTAssertEqual(rotation.adding(clockwise: 1), .zero)
        }
    }

    func testEveryRotationPreservesScaleAndActuallyRotatesPixels() throws {
        let image = CameraImageFixture.image(scale: 2)
        XCTAssertTrue(CameraImageRotator().rotate(image, by: .zero) === image)
        let samples: [(CameraImageRotation, CGPoint, CGPoint)] = [
            (.zero, CGPoint(x: 10, y: 10), CGPoint(x: 60, y: 10)),
            (.ninety, CGPoint(x: 10, y: 10), CGPoint(x: 10, y: 60)),
            (.oneEighty, CGPoint(x: 60, y: 10), CGPoint(x: 10, y: 10)),
            (.twoSeventy, CGPoint(x: 10, y: 60), CGPoint(x: 10, y: 10)),
        ]
        for (rotation, redPoint, bluePoint) in samples {
            let result = CameraImageRotator().rotate(image, by: rotation)
            XCTAssertEqual(result.scale, 2)
            XCTAssertEqual(result.imageOrientation, .up)
            let red = try pixel(result, at: redPoint)
            let blue = try pixel(result, at: bluePoint)
            XCTAssertGreaterThan(red[0], 240)
            XCTAssertLessThan(red[2], 15)
            XCTAssertGreaterThan(blue[2], 240)
            XCTAssertLessThan(blue[0], 15)
        }
    }

    func testROIFrameFitsBothAxesAndCentersWithinOffsetBounds() {
        let frame = CGRect(x: 20, y: 30, width: 200, height: 100)
        XCTAssertEqual(
            ROISelectionFrameCalculator.maximumFrame(aspectRatio: CGSize(width: 1, height: 1), in: frame),
            CGRect(x: 70, y: 30, width: 100, height: 100))
        XCTAssertEqual(
            ROISelectionFrameCalculator.maximumFrame(aspectRatio: CGSize(width: 4, height: 1), in: frame),
            CGRect(x: 20, y: 55, width: 200, height: 50))
    }

    func testROIRejectsEveryInvalidDimension() {
        for invalid: CGFloat in [0, -1, .infinity, -.infinity, .nan] {
            for size in [CGSize(width: invalid, height: 100), CGSize(width: 100, height: invalid)] {
                XCTAssertEqual(
                    ROISelectionFrameCalculator.maximumFrame(
                        aspectRatio: size, in: CGRect(x: 0, y: 0, width: 100, height: 100)), .zero)
                XCTAssertEqual(
                    ROISelectionFrameCalculator.maximumFrame(
                        aspectRatio: CGSize(width: 1, height: 1), in: CGRect(origin: .zero, size: size)), .zero)
            }
        }
    }

    private func pixel(_ image: UIImage, at point: CGPoint) throws -> [UInt8] {
        let source = try XCTUnwrap(
            image.cgImage?.cropping(to: CGRect(x: point.x * image.scale, y: point.y * image.scale, width: 1, height: 1))
        )
        var bytes = [UInt8](repeating: 0, count: 4)
        let context = try XCTUnwrap(
            CGContext(
                data: &bytes, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.draw(source, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        return bytes
    }
}
