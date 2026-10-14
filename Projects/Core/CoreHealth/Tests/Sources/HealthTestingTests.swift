//
//  HealthTestingTests.swift
//  CoreHealthTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreHealthInterface
import CoreHealthTesting
import Foundation
import XCTest

final class HealthTestingTests: XCTestCase {
    private let startDate = Date(timeIntervalSince1970: 100)
    private let endDate = Date(timeIntervalSince1970: 200)

    func testUseCaseStubProvidesIndependentRangeAndMonthResultsThroughInterface() async throws {
        let sut: any HealthUseCaseProtocol = HealthUseCaseStub(
            stepCountResult: .success(3_400),
            monthStepCountResult: .success(42_000)
        )
        let range = try await sut.getStepCount(from: startDate, to: endDate)
        let month = try await sut.getCurrentMonthStepCount()

        XCTAssertEqual(range, 3_400)
        XCTAssertEqual(month, 42_000)
    }

    func testUseCaseStubPropagatesConfiguredFailures() async {
        let sut = HealthUseCaseStub(
            stepCountResult: .failure(CoreHealthError.healthDataUnavailable),
            monthStepCountResult: .failure(CoreHealthError.stepCountQueryFailed)
        )
        await XCTAssertThrowsErrorAsync({ try await sut.getStepCount(from: self.startDate, to: self.endDate) }) {
            XCTAssertEqual($0 as? CoreHealthError, .healthDataUnavailable)
        }
        await XCTAssertThrowsErrorAsync({ try await sut.getCurrentMonthStepCount() }) {
            XCTAssertEqual($0 as? CoreHealthError, .stepCountQueryFailed)
        }
    }

    func testUnconfiguredUseCaseStubCallsThrowInsteadOfHidingMissingSetup() async {
        let sut = HealthUseCaseStub()
        await XCTAssertThrowsErrorAsync({ try await sut.getStepCount(from: self.startDate, to: self.endDate) }) {
            XCTAssertEqual($0 as? CoreHealthStubError, .unexpectedCall("getStepCount"))
        }
        await XCTAssertThrowsErrorAsync({ try await sut.getCurrentMonthStepCount() }) {
            XCTAssertEqual($0 as? CoreHealthStubError, .unexpectedCall("getCurrentMonthStepCount"))
        }
    }

    func testUseCaseHandlerReceivesExactDatesAndReadsChangingScenarioData() async throws {
        var receivedRanges: [(Date, Date)] = []
        var steps = 3_400
        let sut = HealthUseCaseStub(
            getStepCount: { start, end in
                receivedRanges.append((start, end))
                return steps
            },
            getCurrentMonthStepCount: { steps * 10 }
        )
        let initial = try await sut.getStepCount(from: startDate, to: endDate)
        steps = 8_000
        let next = try await sut.getStepCount(from: startDate, to: endDate)
        let month = try await sut.getCurrentMonthStepCount()

        XCTAssertEqual(initial, 3_400)
        XCTAssertEqual(next, 8_000)
        XCTAssertEqual(month, 80_000)
        XCTAssertEqual(receivedRanges.count, 2)
        XCTAssertEqual(receivedRanges.first?.0, startDate)
        XCTAssertEqual(receivedRanges.first?.1, endDate)
    }

    func testHandlerInitializerLeavesUnconfiguredMonthAsUnexpectedCall() async {
        let sut = HealthUseCaseStub(getStepCount: { _, _ in 1 })
        await XCTAssertThrowsErrorAsync({ try await sut.getCurrentMonthStepCount() }) {
            XCTAssertEqual($0 as? CoreHealthStubError, .unexpectedCall("getCurrentMonthStepCount"))
        }
    }

    func testStubHandlersPropagateTheirErrorsWithoutMapping() async {
        let expected = NSError(domain: "DemoScenario", code: 42)
        let sut = HealthUseCaseStub(
            getStepCount: { _, _ in throw expected },
            getCurrentMonthStepCount: { throw expected }
        )
        await XCTAssertThrowsErrorAsync({ try await sut.getStepCount(from: self.startDate, to: self.endDate) }) {
            XCTAssertEqual($0 as NSError, expected)
        }
        await XCTAssertThrowsErrorAsync({ try await sut.getCurrentMonthStepCount() }) {
            XCTAssertEqual($0 as NSError, expected)
        }
    }

    func testCancellationDuringStubDelayPreventsRangeAndMonthHandlers() async {
        var handlerCount = 0
        let sut = HealthUseCaseStub(
            getStepCount: { _, _ in handlerCount += 1; return 1 },
            getCurrentMonthStepCount: { handlerCount += 1; return 2 },
            responseDelay: .seconds(60)
        )
        let rangeTask = Task { try await sut.getStepCount(from: self.startDate, to: self.endDate) }
        rangeTask.cancel()
        await XCTAssertThrowsErrorAsync({ try await rangeTask.value }) {
            XCTAssertTrue($0 is CancellationError)
        }
        let monthTask = Task { try await sut.getCurrentMonthStepCount() }
        monthTask.cancel()
        await XCTAssertThrowsErrorAsync({ try await monthTask.value }) {
            XCTAssertTrue($0 is CancellationError)
        }
        XCTAssertEqual(handlerCount, 0)
    }

    func testDelayedStubReturnsConfiguredResult() async throws {
        let sut = HealthUseCaseStub(stepCountResult: .success(10), responseDelay: .milliseconds(1))
        let value = try await sut.getStepCount(from: startDate, to: endDate)
        XCTAssertEqual(value, 10)
    }

    func testPermissionStubSupportsEveryPromptAndRequestCombinationThroughInterface() async {
        for prompt in [true, false] {
            for requestResult in [true, false] {
                let sut: any HealthPermissionInterface = HealthPermissionStub(
                    shouldShowPrompt: prompt,
                    requestResult: requestResult
                )
                let shouldPrompt = await sut.shouldShowHealthPermissionPrompt()
                let requested = await sut.requestHealthPermission()
                XCTAssertEqual(shouldPrompt, prompt)
                XCTAssertEqual(requested, requestResult)
            }
        }
    }

    func testPermissionHandlersObserveChangingStateAndStayIndependent() async {
        var shouldPrompt = true
        var checkCount = 0
        var requestCount = 0
        let sut = HealthPermissionStub(
            shouldShowPrompt: {
                checkCount += 1
                return shouldPrompt
            },
            requestPermission: {
                requestCount += 1
                shouldPrompt = false
                return true
            }
        )
        let initial = await sut.shouldShowHealthPermissionPrompt()
        let requested = await sut.requestHealthPermission()
        let subsequent = await sut.shouldShowHealthPermissionPrompt()

        XCTAssertTrue(initial)
        XCTAssertTrue(requested)
        XCTAssertFalse(subsequent)
        XCTAssertEqual(checkCount, 2)
        XCTAssertEqual(requestCount, 1)
    }
}
