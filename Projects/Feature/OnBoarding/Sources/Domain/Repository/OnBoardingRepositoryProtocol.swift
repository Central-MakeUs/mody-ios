//
//  OnBoardingRepositoryProtocol.swift
//  OnBoarding
//
//  Created by 김동준 on 7/8/26
//

public protocol OnBoardingRepositoryProtocol {
    func postSetupOnBoardingProfileInfo(request: OnBoardingProfileRequest) async throws
}
