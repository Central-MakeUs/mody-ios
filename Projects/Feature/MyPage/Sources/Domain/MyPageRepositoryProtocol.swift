//
//  MyPageRepositoryProtocol.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import CommonDomain

public protocol MyPageRepositoryProtocol {
    func getMyPageProfile() async throws -> MyPageProfile
    func updateMyPageProfile(_ request: MyPageProfileUpdateRequest) async throws
    func getWeightRecord() async throws -> WeightRecord
    func postRecordWeight(weightKg: Double) async throws
}
