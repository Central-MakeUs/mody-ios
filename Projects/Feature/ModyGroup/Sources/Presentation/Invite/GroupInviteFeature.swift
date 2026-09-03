//
//  GroupInviteFeature.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture
import CoreAnalyticsInterface

@Reducer
public struct GroupInviteFeature {
    private let shareGroupInviteUseCase: ShareGroupInviteUseCaseProtocol
    private let analyticsUseCase: AnalyticsUseCaseProtocol

    public init(
        shareGroupInviteUseCase: ShareGroupInviteUseCaseProtocol,
        analyticsUseCase: AnalyticsUseCaseProtocol
    ) {
        self.shareGroupInviteUseCase = shareGroupInviteUseCase
        self.analyticsUseCase = analyticsUseCase
    }

    @ObservableState
    public struct State: Equatable {
        enum CancelID: Hashable {
            case copyMessage
        }

        var inviteCode: String
        var groupName: String
        var isLoading: Bool = false
        var isCodeCopied: Bool = false

        public init(inviteCode: String = "", groupName: String = "") {
            self.inviteCode = inviteCode
            self.groupName = groupName
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case backButtonTapped
        case copyButtonTapped
        case copyMessageExpired
        case shareButtonTapped
        case shareSucceeded
        case shareFailed
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
                let groupName = state.groupName

                state.isLoading = true
                return .run { send in
                    do {
                        try await shareGroupInviteUseCase.shareCodeToKakao(
                            code: inviteCode,
                            groupName: groupName
                        )
                        await send(.shareSucceeded)
                    } catch {
                        await send(.shareFailed)
                    }
                }
            case .shareSucceeded:
                state.isLoading = false
                return .run { _ in
                    analyticsUseCase.log(ModyGroupAnalyticsEvent.inviteShareSucceeded)
                }
            case .shareFailed:
                state.isLoading = false
                return .none
            case .backButtonTapped, .doneButtonTapped:
                return .none
            }
        }
    }
}
