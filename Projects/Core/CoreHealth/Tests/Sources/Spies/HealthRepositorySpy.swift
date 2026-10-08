//
//  HealthRepositorySpy.swift
//  CoreHealthTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreHealthInterface
import Foundation

final class HealthRepositorySpy: HealthRepositoryProtocol {
    var stepCountResult: Result<Int, Error> = .success(0)
    var monthStepCountResult: Result<Int, Error> = .success(0)
    private(set) var receivedRanges: [(start: Date, end: Date)] = []
    private(set) var monthQueryCount = 0

    func getStepCount(from startDate: Date, to endDate: Date) async throws -> Int {
        receivedRanges.append((startDate, endDate))
        return try stepCountResult.get()
    }

    func getCurrentMonthStepCount() async throws -> Int {
        monthQueryCount += 1
        return try monthStepCountResult.get()
    }
}
