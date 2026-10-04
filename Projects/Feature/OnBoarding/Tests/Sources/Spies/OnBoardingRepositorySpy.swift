//
//  OnBoardingRepositorySpy.swift
//  OnBoardingTests
//
//  Created by 김동준 on 10/4/26.
//

@testable import OnBoarding

final class OnBoardingRepositorySpy: OnBoardingRepositoryProtocol {
    private let result: Result<Int, Error>
    private(set) var requests: [OnBoardingProfileRequest] = []

    init(result: Result<Int, Error> = .success(42)) {
        self.result = result
    }

    func postSetupOnBoardingProfileInfo(request: OnBoardingProfileRequest) async throws -> Int {
        requests.append(request)
        return try result.get()
    }
}
