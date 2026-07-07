//
//  GroupInviteFeature.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture

@Reducer
public struct GroupInviteFeature {
    private let shareGroupInviteUseCase: ShareGroupInviteUseCaseProtocol

    public init(shareGroupInviteUseCase: ShareGroupInviteUseCaseProtocol) {
        self.shareGroupInviteUseCase = shareGroupInviteUseCase
    }

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {
        case backButtonTapped
        case shareButtonTapped
        case doneButtonTapped
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .shareButtonTapped:
                return .run { _ in
                    do {
                        try await shareGroupInviteUseCase.shareCodeToKakao()
                    } catch {
                        debugPrint("ModyGroup invite share failed: \(error)")
                    }
                }
            case .backButtonTapped, .doneButtonTapped:
                return .none
            }
        }
    }
}
