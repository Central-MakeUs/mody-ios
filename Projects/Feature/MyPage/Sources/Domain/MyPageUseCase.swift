//
//  MyPageUseCase.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import CommonDomain

public struct MyPageUseCase {
    private let myPageRepository: MyPageRepositoryProtocol

    public init(myPageRepository: MyPageRepositoryProtocol) {
        self.myPageRepository = myPageRepository
    }

    public func fetchMyPageProfile() async throws -> MyPageProfile {
        try await myPageRepository.getMyPageProfile()
    }

    public func updateMyPageProfile(_ request: MyPageProfileUpdateRequest) async throws {
        try await myPageRepository.updateMyPageProfile(request)
    }

    public func getWeightRecord() async throws -> WeightRecord {
        try await myPageRepository.getWeightRecord()
    }

    public func recordWeight(weightKg: Double) async throws {
        try await myPageRepository.postRecordWeight(weightKg: weightKg)
    }
}
