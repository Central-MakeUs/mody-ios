//
//  OnBoardingAgreementDetailFeature.swift
//  OnBoarding
//
//  Created by 김동준 on 7/26/26.
//

import ComposableArchitecture

@Reducer
public struct OnBoardingAgreementDetailFeature {
    @ObservableState
    public struct State: Equatable {
        let document: OnBoardingAgreementDocument
    }

    public enum Action {
        case backButtonTapped
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}
