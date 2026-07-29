//
//  WeightRecord.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

public struct WeightRecord: Equatable, Sendable {
    public let startWeightKg: Double
    public let currentWeightKg: Double
    public let targetWeightKg: Double

    public init(
        startWeightKg: Double,
        currentWeightKg: Double,
        targetWeightKg: Double
    ) {
        self.startWeightKg = startWeightKg
        self.currentWeightKg = currentWeightKg
        self.targetWeightKg = targetWeightKg
    }
}
