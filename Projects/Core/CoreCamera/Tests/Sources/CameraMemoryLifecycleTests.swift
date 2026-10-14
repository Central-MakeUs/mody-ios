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
    func testCameraViewControllerDeallocatesAfterBindingActions() async {
        weak var weakViewController: CameraContainerViewController?

        autoreleasepool {
            var viewController: CameraContainerViewController? = CameraContainerViewController(
                initialSource: .photoLibrary,
                capturedPhotoProcessor: CameraCapturedPhotoProcessor(
                    temporaryImageFileUseCase: CameraTemporaryImageFileSpy(),
                    previewMaxPixelSize: 100
                ),
                onEvent: { _ in },
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
