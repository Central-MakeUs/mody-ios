//
//  HealthUseCase.swift
//  CoreHealth
//
//  Created by 김동준 on 8/4/26.
//

import CoreHealthInterface
import Foundation

public struct HealthUseCase: HealthUseCaseProtocol {
    private let healthRepository: HealthRepositoryProtocol

    public init(healthRepository: HealthRepositoryProtocol) {
        self.healthRepository = healthRepository
    }

    public func getStepCount(from startDate: Date, to endDate: Date) async throws -> Int {
        guard startDate <= endDate else {
            throw CoreHealthError.invalidDateRange
        }

        return try await healthRepository.getStepCount(from: startDate, to: endDate)
    }

    public func getCurrentMonthStepCount() async throws -> Int {
        try await healthRepository.getCurrentMonthStepCount()
    }
}
