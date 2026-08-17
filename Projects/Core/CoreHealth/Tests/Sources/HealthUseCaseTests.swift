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
    func testGetStepCountForwardsDateRangeAndReturnsRepositoryValue() async throws {
        let repository = HealthRepositorySpy(stepCount: 7_531)
        let useCase = HealthUseCase(healthRepository: repository)
        let startDate = Date(timeIntervalSince1970: 100)
        let endDate = Date(timeIntervalSince1970: 200)

        let stepCount = try await useCase.getStepCount(
            from: startDate,
            to: endDate
        )

        XCTAssertEqual(stepCount, 7_531)
        XCTAssertEqual(repository.receivedStartDate, startDate)
        XCTAssertEqual(repository.receivedEndDate, endDate)
    }

    func testGetStepCountRejectsInvalidDateRangeWithoutCallingRepository() async {
        let repository = HealthRepositorySpy(stepCount: 0)
        let useCase = HealthUseCase(healthRepository: repository)
        let startDate = Date(timeIntervalSince1970: 200)
        let endDate = Date(timeIntervalSince1970: 100)

        do {
            _ = try await useCase.getStepCount(from: startDate, to: endDate)
            XCTFail("Expected invalidDateRange error")
        } catch let error as CoreHealthError {
            XCTAssertEqual(error, .invalidDateRange)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertNil(repository.receivedStartDate)
        XCTAssertNil(repository.receivedEndDate)
    }
}

private final class HealthRepositorySpy: HealthRepositoryProtocol {
    private let stepCount: Int
    private(set) var receivedStartDate: Date?
    private(set) var receivedEndDate: Date?

    init(stepCount: Int) {
        self.stepCount = stepCount
    }

    func getStepCount(from startDate: Date, to endDate: Date) async throws -> Int {
        receivedStartDate = startDate
        receivedEndDate = endDate
        return stepCount
    }

    func getCurrentMonthStepCount() async throws -> Int {
        stepCount
    }
}
