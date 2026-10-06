//  ChallengeHealthDummy.swift
//  ChallengeTests
//
//  Created by 김동준 on 10/6/26.
//

import CoreHealthInterface
import Foundation
import XCTest

struct ChallengeHealthDummy: HealthUseCaseProtocol {
    func getStepCount(from startDate: Date, to endDate: Date) async throws -> Int {
        XCTFail("Unexpected HealthKit request")
        return 0
    }

    func getCurrentMonthStepCount() async throws -> Int {
        XCTFail("Unexpected HealthKit request")
        return 0
    }
}
