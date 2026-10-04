//
//  OnBoardingDemoRepositoryStub.swift
//  OnBoardingDemo
//
//  Created by 김동준 on 10/4/26.
//

import OnBoarding

struct OnBoardingDemoRepositoryStub: OnBoardingRepositoryProtocol {
    private let result: Result<Int, Error>

    init(result: Result<Int, Error>) {
        self.result = result
    }

    func postSetupOnBoardingProfileInfo(request: OnBoardingProfileRequest) async throws -> Int {
        try await Task.sleep(for: .milliseconds(500))
        return try result.get()
    }
}
