//  NotificationTestingTests.swift
//  CoreNotificationTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreNotificationInterface
import CoreNotificationTesting
import XCTest

final class NotificationTestingTests: XCTestCase {
    func testFixedResultsAreIndependentAcrossAllCombinations() async {
        for notDetermined in [true, false] {
            for granted in [true, false] {
                for requested in [true, false] {
                    let sut: NotificationPermissionInterface = NotificationPermissionStub(
                        isNotDetermined: notDetermined, isGranted: granted, requestResult: requested
                    )

                    let prompt = await sut.isNotificationPermissionNotDetermined()
                    let current = await sut.isNotificationPermissionGranted()
                    let result = await sut.requestNotificationPermission()

                    XCTAssertEqual(prompt, notDetermined)
                    XCTAssertEqual(current, granted)
                    XCTAssertEqual(result, requested)
                }
            }
        }
    }

    func testHandlersAreEvaluatedOnEveryCall() async {
        let state = PermissionState()
        let sut = NotificationPermissionStub(
            isNotDetermined: { await state.notDetermined },
            isGranted: { await state.granted },
            requestPermission: { await state.request() }
        )

        let initialPrompt = await sut.isNotificationPermissionNotDetermined()
        let initialGranted = await sut.isNotificationPermissionGranted()
        let requested = await sut.requestNotificationPermission()
        let finalPrompt = await sut.isNotificationPermissionNotDetermined()
        let finalGranted = await sut.isNotificationPermissionGranted()

        XCTAssertTrue(initialPrompt)
        XCTAssertFalse(initialGranted)
        XCTAssertTrue(requested)
        XCTAssertFalse(finalPrompt)
        XCTAssertTrue(finalGranted)
    }
}

private actor PermissionState {
    private(set) var notDetermined = true
    private(set) var granted = false

    func request() -> Bool {
        notDetermined = false
        granted = true
        return true
    }
}
