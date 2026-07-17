//
//  WeightRecordResponse.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

struct WeightRecordResponse: Decodable, Equatable {
    let startWeightKg: Double?
    let currentWeightKg: Double?
    let targetWeightKg: Double?
}

extension WeightRecordResponse {
    func toDomain() -> WeightRecord {
        return WeightRecord(
            startWeightKg: startWeightKg ?? 0,
            currentWeightKg: currentWeightKg ?? 0,
            targetWeightKg: targetWeightKg ?? 0
        )
    }
}
