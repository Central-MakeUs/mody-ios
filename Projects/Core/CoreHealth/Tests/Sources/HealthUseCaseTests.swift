//
//  HealthUseCaseTests.swift
//  CoreHealthTests
//
//  Created by 김동준 on 8/4/26.
//

import CoreHealthInterface
import Foundation
import XCTest

@testable import CoreHealth

final class HealthUseCaseTests: XCTestCase {
    private let startDate = Date(timeIntervalSince1970: 100)
    private let endDate = Date(timeIntervalSince1970: 200)

    func testGetStepCountForwardsDateRangeAndReturnsRepositoryValue() async throws {
        let repository = HealthRepositorySpy()
        repository.stepCountResult = .success(7_531)
        let sut = HealthUseCase(healthRepository: repository)

        let value = try await sut.getStepCount(from: startDate, to: endDate)

        XCTAssertEqual(value, 7_531)
        XCTAssertEqual(repository.receivedRanges.count, 1)
        XCTAssertEqual(repository.receivedRanges.first?.start, startDate)
        XCTAssertEqual(repository.receivedRanges.first?.end, endDate)
        XCTAssertEqual(repository.monthQueryCount, 0)
    }

    func testGetStepCountRejectsInvalidDateRangeWithoutCallingRepository() async {
        let repository = HealthRepositorySpy()
        let sut = HealthUseCase(healthRepository: repository)

        await XCTAssertThrowsErrorAsync({ try await sut.getStepCount(from: endDate, to: startDate) }) {
            XCTAssertEqual($0 as? CoreHealthError, .invalidDateRange)
        }

        XCTAssertTrue(repository.receivedRanges.isEmpty)
        XCTAssertEqual(repository.monthQueryCount, 0)
    }

    func testEqualDatesAreAllowed() async throws {
        let repository = HealthRepositorySpy()
        let sut = HealthUseCase(healthRepository: repository)

        let value = try await sut.getStepCount(from: startDate, to: startDate)

        XCTAssertEqual(value, 0)
        XCTAssertEqual(repository.receivedRanges.count, 1)
        XCTAssertEqual(repository.receivedRanges.first?.start, startDate)
        XCTAssertEqual(repository.receivedRanges.first?.end, startDate)
    }

    func testInvalidRangeTakesPrecedenceOverRepositoryError() async {
        let repository = HealthRepositorySpy()
        repository.stepCountResult = .failure(CoreHealthError.healthDataUnavailable)
        let sut = HealthUseCase(healthRepository: repository)

        await XCTAssertThrowsErrorAsync({ try await sut.getStepCount(from: endDate, to: startDate) }) {
            XCTAssertEqual($0 as? CoreHealthError, .invalidDateRange)
        }
        XCTAssertTrue(repository.receivedRanges.isEmpty)
    }

    func testRangeErrorsAndCancellationPropagateUnchanged() async {
        for error in [CoreHealthError.healthDataUnavailable as Error, CoreHealthError.stepCountQueryFailed,
                      NSError(domain: "HealthTest", code: 42), CancellationError()] {
            let repository = HealthRepositorySpy()
            repository.stepCountResult = .failure(error)
            let sut = HealthUseCase(healthRepository: repository)

            await XCTAssertThrowsErrorAsync({ try await sut.getStepCount(from: self.startDate, to: self.endDate) }) {
                XCTAssertEqual($0 as NSError, error as NSError)
            }
            XCTAssertEqual(repository.receivedRanges.count, 1)
        }
    }

    func testCurrentMonthReturnsRepositoryResultWithoutRangeQuery() async throws {
        for expected in [0, 42_000] {
            let repository = HealthRepositorySpy()
            repository.monthStepCountResult = .success(expected)
            let sut = HealthUseCase(healthRepository: repository)

            let value = try await sut.getCurrentMonthStepCount()

            XCTAssertEqual(value, expected)
            XCTAssertEqual(repository.monthQueryCount, 1)
            XCTAssertTrue(repository.receivedRanges.isEmpty)
        }
    }

    func testCurrentMonthErrorsAndCancellationPropagateUnchanged() async {
        for error in [CoreHealthError.healthDataUnavailable as Error, CoreHealthError.stepCountQueryFailed,
                      NSError(domain: "HealthTest", code: 42), CancellationError()] {
            let repository = HealthRepositorySpy()
            repository.monthStepCountResult = .failure(error)
            let sut = HealthUseCase(healthRepository: repository)

            await XCTAssertThrowsErrorAsync({ try await sut.getCurrentMonthStepCount() }) {
                XCTAssertEqual($0 as NSError, error as NSError)
            }
            XCTAssertEqual(repository.monthQueryCount, 1)
            XCTAssertTrue(repository.receivedRanges.isEmpty)
        }
    }
}
