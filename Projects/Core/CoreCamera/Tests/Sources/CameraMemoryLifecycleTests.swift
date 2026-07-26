//
//  CameraMemoryLifecycleTests.swift
//  CoreCameraTests
//
//  Created by 김동준 on 7/25/26.
//

import CoreCameraInterface
import CoreModyImageInterface
import XCTest
@testable import CoreCamera

final class CameraMemoryLifecycleTests: XCTestCase {
    @MainActor
    func testCameraViewControllerDeallocatesAfterBindingActions() {
        weak var weakViewController: CameraContainerViewController?

        autoreleasepool {
            var viewController: CameraContainerViewController? = CameraContainerViewController(
                initialSource: .photoLibrary,
                capturedPhotoProcessor: CameraCapturedPhotoProcessor(
                    temporaryImageFileUseCase: TemporaryImageFileUseCaseStub(),
                    previewMaxPixelSize: 100
                ),
                onComplete: { _ in },
                onCancel: {}
            )
            viewController?.loadViewIfNeeded()
            weakViewController = viewController
            viewController = nil
        }

        XCTAssertNil(weakViewController)
    }
}

private struct TemporaryImageFileUseCaseStub: TemporaryImageFileUseCaseProtocol {
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
