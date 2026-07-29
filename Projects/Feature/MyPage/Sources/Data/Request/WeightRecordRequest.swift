//
//  WeightRecordRequest.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

struct WeightRecordRequest: Encodable, Equatable {
    let recordedOn: String
    let weightKg: Double
}
