//  CameraViewControllerTests.swift
//  CoreCameraTests
//
//  Created by 김동준 on 10/9/26.
//

import AVFoundation
import CoreCameraInterface
import CoreCameraTesting
import PhotosUI
import UIKit
import XCTest

@testable import CoreCamera

@MainActor
final class CameraViewControllerTests: XCTestCase {
    func testBuilderForwardsCropConfigurationAndCallbacks() throws {
        let files = CameraTemporaryImageFileSpy()
        var completed: CameraCaptureResult?
        var cancelled = 0
        var events: [CameraCaptureEvent] = []
        let controller = try XCTUnwrap(
            CameraCaptureBuilder(temporaryImageFileUseCase: files).makeCameraViewController(
                source: .photoLibrary, isCropEnabled: false, cropAspectRatio: CGSize(width: 1, height: 1),
                onEvent: { events.append($0) }, onComplete: { completed = $0 }, onCancel: { cancelled += 1 }
            ) as? CameraContainerViewController)
        controller.loadViewIfNeeded()
        let photo = CameraImageFixture.photo()
        controller.setCapturedPhoto(photo)
        controller.completeCapture()
        XCTAssertTrue(completed?.croppedPreviewImage === photo.previewImage)
        XCTAssertEqual(completed?.originalFile.fileURL, photo.originalFile.fileURL)
        XCTAssertNil(controller.roiOverlayView.superview)
        XCTAssertEqual(
            controller.closeButton.actions(forTarget: controller, forControlEvent: .touchUpInside), ["closeTapped"])
        controller.closeTapped()
        XCTAssertEqual(cancelled, 1)
        XCTAssertTrue(events.isEmpty)
        XCTAssertTrue(files.calls.isEmpty, "Ownership transfers to the consumer on completion")
    }

    func testReplacingAndClosingPhotoRemovesEachOwnedFileAndClearsImage() {
        let files = CameraTemporaryImageFileSpy()
        let controller = makeSUT(files: files)
        let first = CameraImageFixture.photo(fileName: "first")
        let second = CameraImageFixture.photo(fileName: "second")
        controller.setCapturedPhoto(first)
        controller.setCapturedPhoto(second)
        XCTAssertEqual(files.calls, [.remove(first.originalFile.fileURL)])
        XCTAssertTrue(controller.previewView.isHidden)
        XCTAssertFalse(controller.selectedImageView.isHidden)
        XCTAssertTrue(controller.bottomCameraShutterView.isHidden)
        XCTAssertFalse(controller.photoConfirmationContainerView.isHidden)
        controller.closeTapped()
        XCTAssertEqual(files.calls, [.remove(first.originalFile.fileURL), .remove(second.originalFile.fileURL)])
        XCTAssertNil(controller.capturedPhoto)
        XCTAssertNil(controller.selectedImageView.image)
    }

    func testCompletionWithoutPhotoOrPreviewOrValidCropDoesNotEmitOrDelete() {
        let files = CameraTemporaryImageFileSpy()
        let controller = makeSUT(
            files: files, crop: true, onComplete: { _ in XCTFail("Invalid capture must not complete") })
        controller.completeCapture()
        controller.setCapturedPhoto(CameraImageFixture.photo())
        controller.rotatedPreviewImage = nil
        controller.completeCapture()
        controller.rotatedPreviewImage = CameraImageFixture.image()
        controller.roiOverlayView.bounds = .zero
        controller.completeCapture()
        XCTAssertTrue(files.calls.isEmpty)
        XCTAssertNotNil(controller.capturedPhoto)
    }

    func testCropCompletionTransfersNormalizedFrameAndCannotCompleteTwice() throws {
        let files = CameraTemporaryImageFileSpy()
        var results: [CameraCaptureResult] = []
        let controller = makeSUT(files: files, crop: true, onComplete: { results.append($0) })
        controller.view.frame = CGRect(x: 0, y: 0, width: 300, height: 600)
        controller.view.layoutIfNeeded()
        let photo = CameraImageFixture.photo()
        controller.setCapturedPhoto(photo)
        let expected = try XCTUnwrap(
            CameraImageCropper().crop(
                image: photo.previewImage, selectionFrame: controller.roiOverlayView.selectionFrame,
                containerSize: controller.roiOverlayView.bounds.size, displayMode: .aspectFit))
        controller.completeCapture()
        controller.completeCapture()
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.normalizedSelectionFrame, expected.normalizedSelectionFrame)
        XCTAssertTrue(files.calls.isEmpty)
        XCTAssertNil(controller.capturedPhoto)
        XCTAssertNil(controller.selectedImageView.image)
    }

    func testRotatedCompletionTransfersNewFileAndSaveFailureRetainsPhoto() throws {
        for fails in [false, true] {
            let files = CameraTemporaryImageFileSpy()
            let processor = CameraCapturedPhotoProcessor(temporaryImageFileUseCase: files, previewMaxPixelSize: 100)
            let photo = try processor.makeCapturedPhoto(
                data: XCTUnwrap(CameraImageFixture.image().pngData()), fileName: "photo")
            var results: [CameraCaptureResult] = []
            let controller = makeSUT(files: files, onComplete: { results.append($0) })
            controller.setCapturedPhoto(photo)
            controller.imageRotation = .ninety
            controller.rotatedPreviewImage = CameraImageRotator().rotate(photo.previewImage, by: .ninety)
            if fails { files.saveError = CocoaError(.fileWriteOutOfSpace) }
            controller.completeCapture()
            XCTAssertEqual(results.count, fails ? 0 : 1)
            XCTAssertEqual(controller.capturedPhoto != nil, fails)
            if !fails { XCTAssertNotEqual(results.first?.originalFile.fileURL, photo.originalFile.fileURL) }
        }
    }

    func testRetakeResetsRotationClearsFileAndRestartsSession() async {
        let hardware = CameraSessionHardwareSpy()
        let queue = DispatchQueue(label: "test.camera.view")
        let started = expectation(description: "retake starts session")
        hardware.onStart = { started.fulfill() }
        let files = CameraTemporaryImageFileSpy()
        var events: [CameraCaptureEvent] = []
        let controller = makeSUT(files: files, hardware: hardware, queue: queue, onEvent: { events.append($0) })
        let photo = CameraImageFixture.photo()
        controller.setCapturedPhoto(photo)
        controller.imageRotation = .ninety
        controller.isRotatingPhoto = true
        controller.selectedImageView.transform = CGAffineTransform(rotationAngle: 1)
        controller.photoConfirmationContainerView.onRetakeTap?()
        await fulfillment(of: [started], timeout: 2)
        queue.sync {}
        XCTAssertEqual(events, [.buttonClicked(.retake)])
        XCTAssertEqual(files.calls, [.remove(photo.originalFile.fileURL)])
        XCTAssertEqual(controller.imageRotation, .zero)
        XCTAssertFalse(controller.isRotatingPhoto)
        XCTAssertNil(controller.rotatedPreviewImage)
        XCTAssertEqual(controller.selectedImageView.transform, .identity)
        XCTAssertFalse(controller.previewView.isHidden)
        XCTAssertTrue(controller.selectedImageView.isHidden)
        XCTAssertTrue(controller.rotationControlsView.isHidden)
        XCTAssertFalse(controller.bottomCameraShutterView.isHidden)
        XCTAssertTrue(controller.photoConfirmationContainerView.isHidden)
        XCTAssertTrue(controller.roiOverlayView.isHidden)
    }

    func testShutterAndSwitchEmitInteractionsAndForwardToSession() {
        let hardware = CameraSessionHardwareSpy()
        let queue = DispatchQueue(label: "test.camera.view")
        var events: [CameraCaptureEvent] = []
        let controller = makeSUT(hardware: hardware, queue: queue, onEvent: { events.append($0) })
        controller.bottomCameraShutterView.onCaptureTap?()
        controller.bottomCameraShutterView.onSwitchCameraTap?()
        queue.sync {}
        XCTAssertEqual(events, [.buttonClicked(.takeAPicture), .buttonClicked(.switchCamera)])
        XCTAssertEqual(hardware.calls, ["switch"])
        XCTAssertNil(controller.capturedPhoto)
    }

    func testRotationButtonsApplyBothDirectionsAndIgnoreReentrantRotation() {
        let controller = makeSUT()
        controller.rotateCapturedPhoto(clockwiseDegrees: 90)
        XCTAssertEqual(controller.imageRotation, .zero)
        controller.setCapturedPhoto(CameraImageFixture.photo())
        controller.rotationControlsView.onRotateRightTap?()
        XCTAssertEqual(controller.imageRotation, .ninety)
        XCTAssertEqual(controller.rotatedPreviewImage?.size, CGSize(width: 40, height: 80))
        controller.rotationControlsView.onRotateLeftTap?()
        XCTAssertEqual(controller.imageRotation, .zero)
        controller.isRotatingPhoto = true
        controller.rotateCapturedPhoto(clockwiseDegrees: 90)
        XCTAssertEqual(controller.imageRotation, .zero)
        controller.resetRotationState()
        XCTAssertTrue(controller.rotationControlsView.isUserInteractionEnabled)
    }

    func testLibraryTypeSelectionPrefersJPEGThenFirstImageAndRejectsNonImages() {
        XCTAssertEqual(
            CameraContainerViewController.preferredImageType(in: ["public.png", "public.jpeg"]), "public.jpeg")
        XCTAssertEqual(
            CameraContainerViewController.preferredImageType(in: ["public.text", "public.png", "public.heic"]),
            "public.png")
        XCTAssertNil(CameraContainerViewController.preferredImageType(in: ["public.text", "invalid-type"]))
        XCTAssertNil(CameraContainerViewController.preferredImageType(in: []))
    }

    func testLibrarySuccessCopiesFileUpdatesPhotoAndClearsProgress() async throws {
        let source = CameraTemporaryImageFileSpy()
        let input = try source.saveImage(data: XCTUnwrap(CameraImageFixture.image().pngData()), fileName: "input")
        let files = CameraTemporaryImageFileSpy()
        let controller = makeSUT(files: files)
        let provider = CameraItemProviderSpy(identifiers: ["public.png", "public.jpeg"])
        controller.loadPhotoLibraryImage(from: provider, fileName: "library.jpg")
        XCTAssertEqual(provider.requestedTypes, ["public.jpeg"])
        XCTAssertNotNil(controller.photoLibraryLoadID)
        provider.complete(url: input.fileURL)
        try source.removeImage(at: input.fileURL)
        await drainMainQueue()
        XCTAssertEqual(controller.capturedPhoto?.originalFile.fileName, "library.jpg")
        XCTAssertNotEqual(controller.capturedPhoto?.originalFile.fileURL, input.fileURL)
        XCTAssertNil(controller.photoLibraryLoadID)
        XCTAssertNil(controller.photoLibraryLoadProgress)
        XCTAssertTrue(provider.progress.isCancelled)
    }

    func testCancelledOrReplacedLibraryResultIsRemovedWithoutReplacingCurrentRequest() async throws {
        for replace in [false, true] {
            let source = CameraTemporaryImageFileSpy()
            let input = try source.saveImage(data: XCTUnwrap(CameraImageFixture.image().pngData()), fileName: "input")
            let files = CameraTemporaryImageFileSpy()
            let controller = makeSUT(files: files)
            let old = CameraItemProviderSpy()
            controller.loadPhotoLibraryImage(from: old, fileName: "old")
            let new = CameraItemProviderSpy()
            if replace {
                controller.loadPhotoLibraryImage(from: new, fileName: "new")
            } else {
                controller.cancelPhotoLibraryLoad()
            }
            let currentID = controller.photoLibraryLoadID
            old.complete(url: input.fileURL)
            await drainMainQueue()
            XCTAssertTrue(old.progress.isCancelled)
            XCTAssertEqual(controller.photoLibraryLoadID, currentID)
            XCTAssertNil(controller.capturedPhoto)
            XCTAssertEqual(files.calls.count, 2)
            guard case .remove = files.calls.last else { return XCTFail("Late owned file must be removed") }
        }
    }

    func testLibraryFailureRestartsCameraAndClearsProgress() async {
        for corrupt in [false, true] {
            let hardware = CameraSessionHardwareSpy()
            let started = expectation(description: "failed library load resumes camera")
            hardware.onStart = { started.fulfill() }
            let controller = makeSUT(hardware: hardware)
            let provider = CameraItemProviderSpy()
            controller.loadPhotoLibraryImage(from: provider, fileName: "bad")
            provider.complete(
                url: corrupt ? URL(fileURLWithPath: "/missing/\(UUID())") : nil, error: CocoaError(.fileReadUnknown))
            await fulfillment(of: [started], timeout: 2)
            XCTAssertNil(controller.photoLibraryLoadID)
            XCTAssertNil(controller.photoLibraryLoadProgress)
            XCTAssertNil(controller.capturedPhoto)
        }
    }

    func testDeinitCancelsLibraryProgressAndRemovesOwnedFile() async {
        let files = CameraTemporaryImageFileSpy()
        let provider = CameraItemProviderSpy()
        let photo = CameraImageFixture.photo()
        weak var weakController: CameraContainerViewController?
        autoreleasepool {
            var controller: CameraContainerViewController? = makeSUT(files: files)
            controller?.setCapturedPhoto(photo)
            controller?.loadPhotoLibraryImage(from: provider, fileName: "pending")
            weakController = controller
            controller = nil
        }
        XCTAssertNil(weakController)
        XCTAssertTrue(provider.progress.isCancelled)
        XCTAssertEqual(files.calls, [.remove(photo.originalFile.fileURL)])
    }

    func testCompletionDuringRotationWaitsAndLateAnimationCannotRestoreClosedPhoto() {
        var finish: ((Bool) -> Void)?
        var results: [CameraCaptureResult] = []
        let controller = makeSUT(
            animateRotation: { animations, completion in
                animations()
                finish = completion
            }, onComplete: { results.append($0) })
        controller.setCapturedPhoto(CameraImageFixture.photo())
        controller.rotateCapturedPhoto(clockwiseDegrees: 90)
        controller.completeCapture()
        XCTAssertTrue(results.isEmpty)
        controller.closeTapped()
        finish?(true)
        XCTAssertNil(controller.capturedPhoto)
        XCTAssertNil(controller.selectedImageView.image)
    }

    func testOldAnimationCannotReplaceNewPhoto() {
        var finish: ((Bool) -> Void)?
        let controller = makeSUT(animateRotation: { _, completion in finish = completion })
        controller.setCapturedPhoto(CameraImageFixture.photo(fileName: "old"))
        controller.rotateCapturedPhoto(clockwiseDegrees: 90)
        let new = CameraImageFixture.photo(fileName: "new")
        controller.setCapturedPhoto(new)
        finish?(true)
        XCTAssertTrue(controller.selectedImageView.image === new.previewImage)
        XCTAssertEqual(controller.imageRotation, .zero)
        XCTAssertFalse(controller.isRotatingPhoto)
    }

    func testLibraryResultAfterOwnerDeinitRemovesCopiedFile() async throws {
        let source = CameraTemporaryImageFileSpy()
        let input = try source.saveImage(data: XCTUnwrap(CameraImageFixture.image().pngData()), fileName: "input")
        let files = CameraTemporaryImageFileSpy()
        let provider = CameraItemProviderSpy()
        weak var weakController: CameraContainerViewController?
        autoreleasepool {
            var controller: CameraContainerViewController? = makeSUT(files: files)
            weakController = controller
            controller?.loadPhotoLibraryImage(from: provider, fileName: "pending")
            provider.complete(url: input.fileURL)
            controller = nil
        }
        XCTAssertNil(weakController)
        await drainMainQueue()
        XCTAssertEqual(files.calls.count, 2)
        guard case .remove = files.calls.last else { return XCTFail("Copied file must be cleaned up") }
    }

    func testCancelledLibraryFailureDoesNotRestartCameraOrClearNewRequest() async {
        let hardware = CameraSessionHardwareSpy()
        let queue = DispatchQueue(label: "test.camera.view")
        let controller = makeSUT(hardware: hardware, queue: queue)
        let old = CameraItemProviderSpy()
        let new = CameraItemProviderSpy()
        controller.loadPhotoLibraryImage(from: old, fileName: "old")
        controller.loadPhotoLibraryImage(from: new, fileName: "new")
        let current = controller.photoLibraryLoadID
        old.complete(url: nil)
        await drainMainQueue()
        queue.sync { XCTAssertTrue(hardware.calls.isEmpty) }
        XCTAssertEqual(controller.photoLibraryLoadID, current)
        XCTAssertFalse(new.progress.isCancelled)
    }

    func testUnsupportedLibraryProviderRestartsCameraWithoutRequestingFile() async {
        let hardware = CameraSessionHardwareSpy()
        let started = expectation(description: "unsupported provider resumes camera")
        hardware.onStart = { started.fulfill() }
        let controller = makeSUT(hardware: hardware)
        let provider = CameraItemProviderSpy(identifiers: ["public.text"])
        controller.loadPhotoLibraryImage(from: provider, fileName: "text")
        await fulfillment(of: [started], timeout: 2)
        XCTAssertTrue(provider.requestedTypes.isEmpty)
        XCTAssertNil(controller.photoLibraryLoadID)
    }

    func testDisappearStopsSessionAndCancelsPendingCapture() async throws {
        let hardware = CameraSessionHardwareSpy()
        let queue = DispatchQueue(label: "test.camera.view")
        let started = expectation(description: "session running")
        hardware.onStart = { started.fulfill() }
        let controller = makeSUT(hardware: hardware, queue: queue)
        controller.sessionController.start()
        await fulfillment(of: [started], timeout: 2)
        let completion = CameraCaptureCompletionSpy()
        controller.sessionController.capture(completion: completion.record)
        controller.viewWillDisappear(false)
        queue.sync {}
        let id = try XCTUnwrap(hardware.settings.first).uniqueID
        controller.sessionController.finishCapture(uniqueID: id, error: nil) {
            XCTFail("Disappeared capture must be ignored")
            return nil
        }
        XCTAssertTrue(completion.results.isEmpty)
        XCTAssertFalse(hardware.isRunning)
    }

    func testCameraSourceStartsSessionAndSuccessfulCaptureDisplaysOwnedPhoto() async throws {
        let files = CameraTemporaryImageFileSpy()
        let hardware = CameraSessionHardwareSpy()
        let queue = DispatchQueue(label: "test.camera.view")
        let started = expectation(description: "camera source starts")
        hardware.onStart = { started.fulfill() }
        let controller = makeSUT(files: files, source: .camera, hardware: hardware, queue: queue)
        await fulfillment(of: [started], timeout: 2)
        controller.capturePhoto()
        queue.sync {}
        let id = try XCTUnwrap(hardware.settings.last).uniqueID
        let data = try XCTUnwrap(CameraImageFixture.image().pngData())
        controller.sessionController.finishCapture(uniqueID: id, error: nil) { data }
        await drainMainQueue()
        let photo = try XCTUnwrap(controller.capturedPhoto)
        XCTAssertTrue(photo.originalFile.fileName.hasPrefix("MODY_PHOTO_"))
        XCTAssertEqual(try Data(contentsOf: photo.originalFile.fileURL), data)
        XCTAssertTrue(controller.selectedImageView.image === photo.previewImage)
        XCTAssertFalse(controller.selectedImageView.isHidden)
        queue.sync { XCTAssertFalse(hardware.isRunning) }
    }

    func testNilOrCorruptCameraDataDoesNotEnterConfirmation() async throws {
        for data: Data? in [nil, Data([1, 2, 3])] {
            let files = CameraTemporaryImageFileSpy()
            let hardware = CameraSessionHardwareSpy()
            let queue = DispatchQueue(label: "test.camera.view")
            let started = expectation(description: "camera starts")
            hardware.onStart = { started.fulfill() }
            let controller = makeSUT(files: files, source: .camera, hardware: hardware, queue: queue)
            await fulfillment(of: [started], timeout: 2)
            controller.capturePhoto()
            queue.sync {}
            controller.sessionController.finishCapture(
                uniqueID: try XCTUnwrap(hardware.settings.last).uniqueID, error: nil
            ) { data }
            await drainMainQueue()
            XCTAssertNil(controller.capturedPhoto)
            XCTAssertTrue(controller.selectedImageView.isHidden)
            XCTAssertEqual(files.calls.count, data == nil ? 0 : 2)
        }
    }

    func testOwnerReleasedBeforeCameraDeliveryRemovesOwnedFile() async throws {
        let files = CameraTemporaryImageFileSpy()
        let hardware = CameraSessionHardwareSpy()
        let queue = DispatchQueue(label: "test.camera.view")
        let started = expectation(description: "camera starts")
        hardware.onStart = { started.fulfill() }
        var controller: CameraContainerViewController? = makeSUT(
            files: files, source: .camera, hardware: hardware, queue: queue)
        await fulfillment(of: [started], timeout: 2)
        let data = try XCTUnwrap(CameraImageFixture.image().pngData())
        weak var weakController = controller
        autoreleasepool {
            controller?.capturePhoto()
            queue.sync {}
            if let id = hardware.settings.last?.uniqueID {
                controller?.sessionController.finishCapture(uniqueID: id, error: nil) { data }
            } else {
                XCTFail("Expected a capture request")
            }
            controller = nil
        }
        XCTAssertNil(weakController)
        await drainMainQueue()
        XCTAssertEqual(files.calls.count, 2)
        guard case .remove = files.calls.last else { return XCTFail("Unclaimed camera file must be removed") }
    }

    private func makeSUT(
        files: CameraTemporaryImageFileSpy = CameraTemporaryImageFileSpy(),
        crop: Bool = false,
        source: CameraCaptureSource = .photoLibrary,
        hardware: CameraSessionHardwareSpy = CameraSessionHardwareSpy(),
        queue: DispatchQueue = DispatchQueue(label: "test.camera.view"),
        animateRotation: @escaping (@escaping () -> Void, @escaping (Bool) -> Void) -> Void = {
            animations, completion in
            animations()
            completion(true)
        },
        onEvent: @escaping (CameraCaptureEvent) -> Void = { _ in },
        onComplete: @escaping (CameraCaptureResult) -> Void = { _ in }
    ) -> CameraContainerViewController {
        let session = CameraCaptureSessionController(
            permissionService: CameraPermissionStub(isNotDetermined: false, isGranted: true, requestResult: false),
            hardware: hardware, sessionQueue: queue)
        let controller = CameraContainerViewController(
            initialSource: source, isCropEnabled: crop,
            capturedPhotoProcessor: CameraCapturedPhotoProcessor(
                temporaryImageFileUseCase: files, previewMaxPixelSize: 100), sessionController: session,
            animateRotation: animateRotation, onEvent: onEvent, onComplete: onComplete, onCancel: {})
        controller.loadViewIfNeeded()
        return controller
    }

    private func drainMainQueue() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }
    }
}
