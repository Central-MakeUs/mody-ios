//  CameraPermissionTests.swift
//  CoreCameraTests
//
//  Created by 김동준 on 10/9/26.
//

import AVFoundation
import XCTest

@testable import CoreCamera

final class CameraPermissionTests: XCTestCase {
    func testEveryAuthorizationStatusMapsToBothQueriesWithoutRequestingPermission() {
        for status: AVAuthorizationStatus in [.notDetermined, .restricted, .denied, .authorized] {
            let sut = CameraPermissionService(
                authorizationStatus: { status },
                requestAccess: {
                    XCTFail("A query must not request permission")
                    return false
                })
            XCTAssertEqual(sut.isCameraPermissionNotDetermined(), status == .notDetermined)
            XCTAssertEqual(sut.isCameraPermissionGranted(), status == .authorized)
        }
    }

    func testQueriesReadCurrentStatusInsteadOfCachingIt() {
        var status = AVAuthorizationStatus.notDetermined
        let sut = CameraPermissionService(authorizationStatus: { status }, requestAccess: { false })
        XCTAssertTrue(sut.isCameraPermissionNotDetermined())
        status = .authorized
        XCTAssertTrue(sut.isCameraPermissionGranted())
        XCTAssertFalse(sut.isCameraPermissionNotDetermined())
        status = .denied
        XCTAssertFalse(sut.isCameraPermissionGranted())
    }

    func testRequestForwardsGrantedAndDeniedResultsExactlyOnce() async {
        for granted in [true, false] {
            var count = 0
            let sut = CameraPermissionService(
                authorizationStatus: {
                    XCTFail("Request must not substitute a status query")
                    return .notDetermined
                },
                requestAccess: {
                    count += 1
                    return granted
                })
            let result = await sut.requestCameraPermission()
            XCTAssertEqual(result, granted)
            XCTAssertEqual(count, 1)
        }
    }
}
