//
//  HealthUseCaseStub.swift
//  CoreHealthTesting
//
//  Created by 김동준 on 10/9/26.
//

import CoreHealthInterface
import Foundation

public struct HealthUseCaseStub: HealthUseCaseProtocol {
    private let stepCountHandler: (Date, Date) async throws -> Int
    private let monthStepCountHandler: () async throws -> Int
    private let responseDelay: Duration

    public init(
        stepCountResult: Result<Int, Error> = .failure(CoreHealthStubError.unexpectedCall("getStepCount")),
        monthStepCountResult: Result<Int, Error> = .failure(CoreHealthStubError.unexpectedCall("getCurrentMonthStepCount")),
        responseDelay: Duration = .zero
    ) {
        self.init(
            getStepCount: { _, _ in try stepCountResult.get() },
            getCurrentMonthStepCount: { try monthStepCountResult.get() },
            responseDelay: responseDelay
        )
    }

    public init(
        getStepCount: @escaping (Date, Date) async throws -> Int,
        getCurrentMonthStepCount: @escaping () async throws -> Int = {
            throw CoreHealthStubError.unexpectedCall("getCurrentMonthStepCount")
        },
        responseDelay: Duration = .zero
    ) {
        self.stepCountHandler = getStepCount
        self.monthStepCountHandler = getCurrentMonthStepCount
        self.responseDelay = responseDelay
    }

    public func getStepCount(from startDate: Date, to endDate: Date) async throws -> Int {
        try await delayResponse()
        return try await stepCountHandler(startDate, endDate)
    }

    public func getCurrentMonthStepCount() async throws -> Int {
        try await delayResponse()
        return try await monthStepCountHandler()
    }

    private func delayResponse() async throws {
        if responseDelay > .zero {
            try await Task.sleep(for: responseDelay)
        }
    }
}
