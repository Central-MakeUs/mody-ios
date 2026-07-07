//
//  GroupInviteFeature.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture

@Reducer
public struct GroupInviteFeature {
    private let inviteCode = "AABB1122"
    private let shareGroupInviteUseCase: ShareGroupInviteUseCaseProtocol

    public init(shareGroupInviteUseCase: ShareGroupInviteUseCaseProtocol) {
        self.shareGroupInviteUseCase = shareGroupInviteUseCase
    }

    @ObservableState
    public struct State: Equatable {
        var isLoading: Bool = false

        public init() {}
    }
    
    public enum Action {
        case backButtonTapped
        case shareButtonTapped
        case shareFinished
        case doneButtonTapped
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .shareButtonTapped:
                guard !state.isLoading else { return .none }

                state.isLoading = true
                return .run { send in
                    do {
                        try await shareGroupInviteUseCase.shareCodeToKakao(code: inviteCode)
                    } catch {
                        debugPrint("ModyGroup invite share failed: \(error)")
                    }
                    await send(.shareFinished)
                }
            case .shareFinished:
                state.isLoading = false
                return .none
            case .backButtonTapped, .doneButtonTapped:
                return .none
            }
        }
    }
}
