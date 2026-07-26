//
//  CameraImageProcessingTests.swift
//  CoreCameraTests
//
//  Created by 김동준 on 7/25/26.
//

import CoreCameraInterface
import CoreModyImageInterface
import UIKit
import XCTest
@testable import CoreCamera

final class CameraImageProcessingTests: XCTestCase {
    func testThumbnailDoesNotExceedMaximumPixelSize() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("png")
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let sourceImage = makeImage(size: CGSize(width: 300, height: 150))
        try XCTUnwrap(sourceImage.pngData()).write(to: fileURL)

        let thumbnail = try XCTUnwrap(
            CameraImageThumbnailGenerator().makeThumbnail(
                fileURL: fileURL,
                maxPixelSize: 100
            )
        )

        XCTAssertLessThanOrEqual(max(thumbnail.size.width, thumbnail.size.height), 100)
        XCTAssertEqual(thumbnail.imageOrientation, .up)
        XCTAssertEqual(thumbnail.scale, 1)
    }

    func testCropUsesScaleOneAndNormalizedCoordinates() throws {
        let cropOutput = try XCTUnwrap(
            CameraImageCropper().crop(
                image: makeImage(size: CGSize(width: 200, height: 100)),
                selectionFrame: CGRect(x: 50, y: 25, width: 100, height: 50),
                containerSize: CGSize(width: 200, height: 100)
            )
        )

        XCTAssertEqual(cropOutput.croppedImage.scale, 1)
        XCTAssertEqual(cropOutput.croppedImage.size, CGSize(width: 100, height: 50))
        XCTAssertEqual(
            cropOutput.normalizedSelectionFrame,
            CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
        )
    }

    @MainActor
    func testCropDisabledReturnsExistingPreviewAndFullFrame() throws {
        let previewImage = makeImage(size: CGSize(width: 300, height: 150))
        var capturedResult: CameraCaptureResult?
        let viewController = CameraContainerViewController(
            initialSource: .photoLibrary,
            isCropEnabled: false,
            capturedPhotoProcessor: CameraCapturedPhotoProcessor(
                temporaryImageFileUseCase: CameraTemporaryImageFileUseCaseStub(),
                previewMaxPixelSize: CameraContainerViewController.previewMaxPixelSize
            ),
            onComplete: { capturedResult = $0 },
            onCancel: {}
        )

        viewController.loadViewIfNeeded()
        viewController.setCapturedPhoto(
            CameraCapturedPhoto(
                originalFile: TemporaryImageFile(
                    fileURL: FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString),
                    fileName: "profile.jpg",
                    contentType: "image/jpeg"
                ),
                previewImage: previewImage
            )
        )
        viewController.completeCapture()

        XCTAssertNil(viewController.roiOverlayView.superview)
        XCTAssertTrue(capturedResult?.croppedPreviewImage === previewImage)
        XCTAssertEqual(
            capturedResult?.normalizedSelectionFrame,
            CGRect(x: 0, y: 0, width: 1, height: 1)
        )
    }
}

private extension CameraImageProcessingTests {
    func makeImage(size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.systemOrange.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

private struct CameraTemporaryImageFileUseCaseStub: TemporaryImageFileUseCaseProtocol {
    func saveImage(
        data: Data,
        fileName: String
    ) throws -> TemporaryImageFile {
        throw CocoaError(.featureUnsupported)
    }

    func copyImage(
        at sourceURL: URL,
        fileName: String
    ) throws -> TemporaryImageFile {
        throw CocoaError(.featureUnsupported)
    }

    func removeImage(at fileURL: URL) throws {}

    func removeExpiredImages(olderThan expirationInterval: TimeInterval) throws {}
}
