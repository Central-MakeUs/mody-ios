//
//  ProfileFeature.swift
//  MyPage
//
//  Created by 김동준 on 7/12/26.
//

import ComposableArchitecture
import CommonDomain
import CoreAuthInterface
import Foundation
import MyPageInterface
import ModyLogger

@Reducer
public struct ProfileFeature {
    private let authUseCase: AuthUseCaseProtocol
    private let router: @MainActor (MyPageProfileRoute) -> Void

    public init(
        authUseCase: AuthUseCaseProtocol,
        router: @escaping @MainActor (MyPageProfileRoute) -> Void
    ) {
        self.authUseCase = authUseCase
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        var isLoading: Bool = false
        var profileImageURL: URL?
        var defaultAvatar: DefaultAvatar

        public init(
            profileImageURL: URL?,
            defaultAvatar: DefaultAvatar
        ) {
            self.profileImageURL = profileImageURL
            self.defaultAvatar = defaultAvatar
        }
    }

    public enum Action {
        case backButtonTapped
        case logoutButtonTapped
        case logoutSuccessfully
        case logoutFailure
        case routeToSignIn
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .run { [router] _ in
                    await router(.back)
                }
            case .logoutButtonTapped:
                state.isLoading = true
                return .run { send in
                    await send(logout())
                }
            case .logoutSuccessfully:
                state.isLoading = false
                return .send(.routeToSignIn)
            case .logoutFailure:
                state.isLoading = false
                return .none
            case .routeToSignIn:
                return .run { [router] _ in
                    await router(.routeToSignIn)
                }
            }
        }
    }
}

private extension ProfileFeature {
    func logout() async -> Action {
        do {
            try await authUseCase.logout()
            return .logoutSuccessfully
        } catch {
            ModyLogger.debug("Logout failed: \(error)")
            return .logoutFailure
        }
    }
}
