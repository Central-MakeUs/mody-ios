//
//  OnBoardingProfileResponse.swift
//  OnBoarding
//
//  Created by 김동준 on 7/8/26
//

public struct OnBoardingProfileResponse: Decodable, Equatable {
    public let memberId: Int?
    public let weightRecordId: Int?
    public let personalInfoCompleted: Bool?
}
