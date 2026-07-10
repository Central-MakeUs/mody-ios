//
//  OnBoardingEndpoint.swift
//  OnBoarding
//
//  Created by 김동준 on 7/8/26
//

import CoreNetworkInterface

enum OnBoardingEndpoint {
    static func postProfile(request: OnBoardingProfileRequest) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/onboarding/profile",
            method: .POST,
            bodyParameters: request
        )
    }
}
