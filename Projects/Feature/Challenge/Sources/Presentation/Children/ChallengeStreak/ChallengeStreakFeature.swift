//
//  ChallengeStreakFeature.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import ComposableArchitecture

@Reducer
public struct ChallengeStreakFeature {
    private let challengeUseCase: ChallengeUseCase

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {}

    public init(challengeUseCase: ChallengeUseCase) {
        self.challengeUseCase = challengeUseCase
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
