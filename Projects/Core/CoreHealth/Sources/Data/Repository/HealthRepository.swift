//
//  HealthRepository.swift
//  CoreHealth
//
//  Created by 김동준 on 8/4/26.
//

import CoreHealthInterface
import Foundation

public struct HealthRepository: HealthRepositoryProtocol {
    private let healthService: HealthService

    public init(healthService: HealthService) {
        self.healthService = healthService
    }

    public func getStepCount(from startDate: Date, to endDate: Date) async throws -> Int {
        try await mapHealthServiceError {
            try await healthService.getStepCount(from: startDate, to: endDate)
        }
    }

    public func getCurrentMonthStepCount() async throws -> Int {
        try await mapHealthServiceError {
            try await healthService.getCurrentMonthStepCount()
        }
    }
}

private extension HealthRepository {
    func mapHealthServiceError(
        operation: () async throws -> Int
    ) async throws -> Int {
        do {
            return try await operation()
        } catch HealthServiceError.healthDataUnavailable {
            throw CoreHealthError.healthDataUnavailable
        } catch {
            throw CoreHealthError.stepCountQueryFailed
        }
    }
}
