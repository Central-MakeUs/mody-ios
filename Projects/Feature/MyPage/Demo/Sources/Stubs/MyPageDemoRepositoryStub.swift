//
//  MyPageDemoRepositoryStub.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import MyPage

actor MyPageDemoProfileData {
    private(set) var name = "동준이"

    func update(name: String) {
        self.name = name
    }
}

struct MyPageDemoRepositoryStub: MyPageRepositoryProtocol {
    private let scenario: MyPageScenario
    private let profileData: MyPageDemoProfileData

    init(scenario: MyPageScenario, profileData: MyPageDemoProfileData) {
        self.scenario = scenario
        self.profileData = profileData
    }

    func getMyPageProfile() async throws -> MyPageProfile {
        if scenario == .profileLookupFailure {
            throw NetworkError.networkUnavailable
        }
        return MyPageProfile(
            socialLoginType: .kakao,
            name: await profileData.name,
            birthDate: "2000-01-01"
        )
    }

    func updateMyPageProfile(_ request: MyPageProfileUpdateRequest) async throws {
        if scenario == .profileSaveFailure {
            throw NetworkError.networkUnavailable
        }
        await profileData.update(name: request.nickname)
    }

    func getWeightRecord() async throws -> WeightRecord {
        if scenario == .weightLookupFailure {
            throw NetworkError.networkUnavailable
        }
        return WeightRecord(startWeightKg: 56, currentWeightKg: 53, targetWeightKg: 50)
    }

    func postRecordWeight(recordedOn: String, weightKg: Double) async throws {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .weightSaveFailure {
            throw NetworkError.networkUnavailable
        }
    }
}
