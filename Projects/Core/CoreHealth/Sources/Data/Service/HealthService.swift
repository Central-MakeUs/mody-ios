//
//  HealthService.swift
//  CoreHealth
//
//  Created by 김동준 on 8/4/26.
//

import Foundation
import HealthKit

public struct HealthService {
    private let healthStore: HKHealthStore

    private static var koreanCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        return calendar
    }

    public init() {
        self.healthStore = HKHealthStore()
    }

    func getStepCount(from startDate: Date, to endDate: Date) async throws -> Int {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthServiceError.healthDataUnavailable
        }

        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            throw HealthServiceError.stepCountTypeUnavailable
        }

        let datePredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        let query = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(
                type: stepCountType,
                predicate: datePredicate
            ),
            options: .cumulativeSum
        )
        let statistics = try await query.result(for: healthStore)
        let stepCount = statistics?
            .sumQuantity()?
            .doubleValue(for: .count()) ?? 0

        return max(Int(stepCount), 0)
    }

    func getCurrentMonthStepCount() async throws -> Int {
        let now = Date()
        guard let startOfMonth = Self.koreanCalendar.dateInterval(
            of: .month,
            for: now
        )?.start else {
            throw HealthServiceError.dateRangeCalculationFailed
        }

        return try await getStepCount(from: startOfMonth, to: now)
    }
}
