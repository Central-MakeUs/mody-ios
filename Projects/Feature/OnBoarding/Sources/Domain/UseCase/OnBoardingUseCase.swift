//
//  OnBoardingUseCase.swift
//  OnBoarding
//
//  Created by 김동준 on 7/8/26
//

public struct OnBoardingUseCase {
    private let onBoardingRepository: OnBoardingRepositoryProtocol

    public init(onBoardingRepository: OnBoardingRepositoryProtocol) {
        self.onBoardingRepository = onBoardingRepository
    }

    public func setupOnBoardingProfileInfo(request: OnBoardingProfileRequest) async throws {
        try await onBoardingRepository.postSetupOnBoardingProfileInfo(request: request)
    }
}
