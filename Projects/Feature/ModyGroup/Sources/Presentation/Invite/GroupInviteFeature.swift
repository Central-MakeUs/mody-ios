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
        enum CancelID: Hashable {
            case copyMessage
        }

        var inviteCode: String
        var isLoading: Bool = false
        var isCodeCopied: Bool = false

        public init(inviteCode: String = "") {
            self.inviteCode = inviteCode
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case backButtonTapped
        case copyButtonTapped
        case copyMessageExpired
        case shareButtonTapped
        case shareFinished
        case doneButtonTapped
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .copyButtonTapped:
                guard !state.inviteCode.isEmpty else { return .none }
                state.isCodeCopied = true

                return .run { send in
                    try await Task.sleep(for: .seconds(2))
                    await send(.copyMessageExpired)
                }
                .cancellable(id: State.CancelID.copyMessage, cancelInFlight: true)
            case .copyMessageExpired:
                state.isCodeCopied = false
                return .none
            case .shareButtonTapped:
                guard !state.isLoading else { return .none }
                let inviteCode = state.inviteCode

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
