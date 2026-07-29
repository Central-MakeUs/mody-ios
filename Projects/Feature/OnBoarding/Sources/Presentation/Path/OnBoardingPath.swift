//
//  OnBoardingPath.swift
//  OnBoarding
//
//  Created by 김동준 on 7/26/26.
//

import ComposableArchitecture

@Reducer
public enum OnBoardingPath {
    case agreementDetail(OnBoardingAgreementDetailFeature)
}

extension OnBoardingPath.State: Equatable {}
