//
//  MyPageRepositorySpy.swift
//  MyPageTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
@testable import MyPage

final class MyPageRepositorySpy: MyPageRepositoryProtocol {
    var profileResult: Result<MyPageProfile, Error> = .success(MyPageFixture.profile)
    var weightResult: Result<WeightRecord, Error> = .success(MyPageFixture.weight)
    var updateResult: Result<Void, Error> = .success(())
    private(set) var profileFetchCount = 0
    private(set) var weightFetchCount = 0
    private(set) var profileRequests: [MyPageProfileUpdateRequest] = []
    private(set) var weightRequests: [(recordedOn: String, weightKg: Double)] = []

    func getMyPageProfile() async throws -> MyPageProfile {
        profileFetchCount += 1
        return try profileResult.get()
    }
    func updateMyPageProfile(_ request: MyPageProfileUpdateRequest) async throws {
        profileRequests.append(request)
        try updateResult.get()
    }
    func getWeightRecord() async throws -> WeightRecord {
        weightFetchCount += 1
        return try weightResult.get()
    }
    func postRecordWeight(recordedOn: String, weightKg: Double) async throws {
        weightRequests.append((recordedOn, weightKg))
        try updateResult.get()
    }
}
