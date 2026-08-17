//
//  HealthRepositoryProtocol.swift
//  CoreHealthInterface
//
//  Created by 김동준 on 8/4/26.
//

import Foundation

public protocol HealthRepositoryProtocol {
    func getStepCount(from startDate: Date, to endDate: Date) async throws -> Int
    func getCurrentMonthStepCount() async throws -> Int
}
