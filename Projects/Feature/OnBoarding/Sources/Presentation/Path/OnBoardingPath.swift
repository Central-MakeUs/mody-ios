//
//  OnBoardingPath.swift
//  OnBoarding
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture

@Reducer
public enum OnBoardingPath {
    case temp(TempFeature)
}

extension OnBoardingPath.State: Equatable {}
