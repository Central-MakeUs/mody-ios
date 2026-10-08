//  CameraCaptureSessionTests.swift
//  CoreCameraTests
//
//  Created by 김동준 on 10/9/26.
//

import AVFoundation
import CoreCameraTesting
import XCTest

@testable import CoreCamera

final class CameraCaptureSessionTests: XCTestCase {
    func testUndeterminedPermissionRequestsOnceAndConfiguresOnlyWhenGranted() async {
        for granted in [true, false] {
            let permissionRead = expectation(description: "permission requested")
            let configured = granted ? expectation(description: "configured") : nil
            let hardware = CameraSessionHardwareSpy()
            hardware.onStart = { configured?.fulfill() }
            let queue = DispatchQueue(label: "test.camera")
            let permission = CameraPermissionService(
                authorizationStatus: { .notDetermined },
                requestAccess: {
                    permissionRead.fulfill()
                    return granted
                })
            let sut = CameraCaptureSessionController(
                permissionService: permission, hardware: hardware, sessionQueue: queue)
            sut.start()
            await fulfillment(of: [permissionRead] + [configured].compactMap { $0 }, timeout: 2)
            queue.sync {
                XCTAssertEqual(hardware.calls, granted ? ["configure", "start"] : [])
                XCTAssertTrue(sut.session === hardware.session)
            }
        }
    }

    func testDeniedAndRestrictedPermissionsNeverConfigureOrRequest() async {
        for status: AVAuthorizationStatus in [.denied, .restricted] {
            let checked = expectation(description: "status checked twice")
            checked.expectedFulfillmentCount = 2
            let hardware = CameraSessionHardwareSpy()
            let queue = DispatchQueue(label: "test.camera")
            let sut = CameraCaptureSessionController(
                permissionService: CameraPermissionService(
                    authorizationStatus: {
                        checked.fulfill()
                        return status
                    },
                    requestAccess: {
                        XCTFail("Must not request determined permission")
                        return true
                    }), hardware: hardware, sessionQueue: queue)
            sut.start()
            await fulfillment(of: [checked], timeout: 2)
            queue.sync { XCTAssertTrue(hardware.calls.isEmpty) }
        }
    }

    func testRepeatedStartConfiguresOnceAndRestartReusesConfiguration() async {
        let hardware = CameraSessionHardwareSpy()
        let queue = DispatchQueue(label: "test.camera")
        let sut = makeSUT(hardware, queue)
        await start(sut, hardware)
        let checked = expectation(description: "already running checked")
        queue.sync {
            hardware.onStart = nil
            hardware.onIsRunningRead = { checked.fulfill() }
        }
        sut.start()
        await fulfillment(of: [checked], timeout: 2)
        queue.sync { hardware.onIsRunningRead = nil }
        sut.stop()
        queue.sync {}
        await start(sut, hardware)
        queue.sync {
            XCTAssertEqual(hardware.calls.filter { $0 == "configure" }.count, 1)
            XCTAssertEqual(hardware.calls.filter { $0 == "stop" }.count, 1)
            XCTAssertTrue(hardware.isRunning)
        }
    }

    func testFailedConfigurationDoesNotStartOrCaptureAndCanRetry() async {
        let hardware = CameraSessionHardwareSpy()
        hardware.configureResult = false
        let queue = DispatchQueue(label: "test.camera")
        let sut = makeSUT(hardware, queue)
        let configured = expectation(description: "failed configuration")
        hardware.onConfigure = { configured.fulfill() }
        sut.start()
        await fulfillment(of: [configured], timeout: 2)
        let result = CameraCaptureCompletionSpy()
        sut.capture(completion: result.record)
        queue.sync {
            XCTAssertEqual(hardware.calls, ["configure"])
            XCTAssertEqual(result.results.count, 1)
            XCTAssertNil(result.results[0])
            hardware.onConfigure = nil
            hardware.configureResult = true
        }
        await start(sut, hardware)
        queue.sync { XCTAssertEqual(hardware.calls, ["configure", "configure", "start"]) }
    }

    func testStopIsIdempotentAndSwitchIsForwarded() async {
        let hardware = CameraSessionHardwareSpy()
        let queue = DispatchQueue(label: "test.camera")
        let sut = makeSUT(hardware, queue)
        sut.stop()
        queue.sync { XCTAssertTrue(hardware.calls.isEmpty) }
        await start(sut, hardware)
        sut.switchCamera()
        sut.stop()
        sut.stop()
        queue.sync { XCTAssertEqual(hardware.calls, ["configure", "start", "switch", "stop"]) }
    }

    func testCaptureBeforeConfigurationCompletesWithNilWithoutHardwareCall() {
        let hardware = CameraSessionHardwareSpy()
        let queue = DispatchQueue(label: "test.camera")
        let sut = makeSUT(hardware, queue)
        let spy = CameraCaptureCompletionSpy()
        sut.capture(completion: spy.record)
        queue.sync {}
        XCTAssertEqual(spy.results.count, 1)
        XCTAssertNil(spy.results[0])
        XCTAssertTrue(hardware.calls.isEmpty)
    }

    func testCaptureSelectsJPEGWhenAvailableAndDefaultSettingsOtherwise() async throws {
        for codecs: [AVVideoCodecType] in [[.jpeg], [.hevc], []] {
            let hardware = CameraSessionHardwareSpy()
            hardware.availablePhotoCodecTypes = codecs
            let queue = DispatchQueue(label: "test.camera")
            let sut = makeSUT(hardware, queue)
            await start(sut, hardware)
            sut.capture { _ in }
            queue.sync {}
            let settings = try XCTUnwrap(hardware.settings.first)
            if codecs.contains(.jpeg) {
                XCTAssertEqual(settings.format?[AVVideoCodecKey] as? AVVideoCodecType, .jpeg)
            } else {
                XCTAssertEqual(settings.format as NSDictionary?, AVCapturePhotoSettings().format as NSDictionary?)
            }
            XCTAssertTrue(hardware.delegate === sut)
        }
    }

    func testDuplicateCaptureIsRejectedAndMatchingCompletionIsDeliveredExactlyOnce() async throws {
        let hardware = CameraSessionHardwareSpy()
        let queue = DispatchQueue(label: "test.camera")
        let sut = makeSUT(hardware, queue)
        await start(sut, hardware)
        let first = CameraCaptureCompletionSpy()
        let duplicate = CameraCaptureCompletionSpy()
        sut.capture(completion: first.record)
        sut.capture(completion: duplicate.record)
        queue.sync {}
        let id = try XCTUnwrap(hardware.settings.first).uniqueID
        XCTAssertEqual(hardware.settings.count, 1)
        XCTAssertEqual(duplicate.results.count, 1)
        XCTAssertNil(duplicate.results[0])
        sut.finishCapture(uniqueID: id + 1, error: nil) {
            XCTFail("Ignore unrelated callback before decoding")
            return nil
        }
        XCTAssertTrue(first.results.isEmpty)
        sut.finishCapture(uniqueID: id, error: nil) { Data([1, 2]) }
        sut.finishCapture(uniqueID: id, error: nil) {
            XCTFail("Ignore duplicate callback")
            return nil
        }
        XCTAssertEqual(first.results, [Data([1, 2])])
        sut.capture { _ in }
        queue.sync { XCTAssertEqual(hardware.settings.count, 2) }
    }

    func testCaptureErrorSkipsDecodingAndNilDataAlsoCompletesAndReleasesPendingSlot() async throws {
        let hardware = CameraSessionHardwareSpy()
        let queue = DispatchQueue(label: "test.camera")
        let sut = makeSUT(hardware, queue)
        await start(sut, hardware)
        for error: Error? in [CocoaError(.fileReadUnknown), nil] {
            let spy = CameraCaptureCompletionSpy()
            sut.capture(completion: spy.record)
            queue.sync {}
            let id = try XCTUnwrap(hardware.settings.last).uniqueID
            sut.finishCapture(uniqueID: id, error: error) {
                XCTAssertNil(error)
                return nil
            }
            XCTAssertEqual(spy.results.count, 1)
            XCTAssertNil(spy.results[0])
        }
        XCTAssertEqual(hardware.settings.count, 2)
    }

    func testCancelIgnoresLateCallbackWithoutClearingNewCapture() async throws {
        let hardware = CameraSessionHardwareSpy()
        let queue = DispatchQueue(label: "test.camera")
        let sut = makeSUT(hardware, queue)
        await start(sut, hardware)
        let old = CameraCaptureCompletionSpy()
        let new = CameraCaptureCompletionSpy()
        sut.capture(completion: old.record)
        sut.cancelPendingCapture()
        sut.capture(completion: new.record)
        queue.sync {}
        XCTAssertEqual(hardware.settings.count, 2)
        sut.finishCapture(uniqueID: hardware.settings[0].uniqueID, error: nil) {
            XCTFail("Cancelled data must not be decoded")
            return nil
        }
        sut.finishCapture(uniqueID: hardware.settings[1].uniqueID, error: nil) { Data([9]) }
        XCTAssertTrue(old.results.isEmpty)
        XCTAssertEqual(new.results, [Data([9])])
    }

    func testQueuedCaptureDoesNotRetainControllerAndCompletesNilAfterDeinit() {
        let hardware = CameraSessionHardwareSpy()
        let queue = DispatchQueue(label: "test.camera")
        var sut: CameraCaptureSessionController? = makeSUT(hardware, queue)
        weak var weakSUT = sut
        let spy = CameraCaptureCompletionSpy()
        queue.suspend()
        sut?.capture(completion: spy.record)
        sut = nil
        XCTAssertNil(weakSUT)
        queue.resume()
        queue.sync {}
        XCTAssertEqual(spy.results.count, 1)
        XCTAssertNil(spy.results[0])
    }

    private func makeSUT(_ hardware: CameraSessionHardwareSpy, _ queue: DispatchQueue) -> CameraCaptureSessionController
    {
        CameraCaptureSessionController(
            permissionService: CameraPermissionStub(isNotDetermined: false, isGranted: true, requestResult: false),
            hardware: hardware, sessionQueue: queue)
    }

    private func start(_ sut: CameraCaptureSessionController, _ hardware: CameraSessionHardwareSpy) async {
        let started = expectation(description: "session started")
        hardware.onStart = { started.fulfill() }
        sut.start()
        await fulfillment(of: [started], timeout: 2)
    }
}
