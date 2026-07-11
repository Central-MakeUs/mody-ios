//
//  SplashFeature.swift
//  Splash
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture
import SplashInterface
import CommonDomain
import CoreAuthInterface

@Reducer
public struct SplashFeature {
    private let splashUseCase: SplashUseCase
    private let authUseCase: AuthUseCaseProtocol
    private let router: @MainActor (SplashRoute) -> Void
    
    public init(
        splashUseCase: SplashUseCase,
        authUseCase: AuthUseCaseProtocol,
        router: @escaping @MainActor (SplashRoute) -> Void
    ) {
        self.splashUseCase = splashUseCase
        self.authUseCase = authUseCase
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var isLoading = true
    }
    
    public enum Action {
        case onAppear
        case serverHealthChecked(Bool)
        case userInfoFetched(AuthSession)
        case userInfoFetchFailed
        case setUpRemoteConfig
        case cachingRemoteConfig
        case healthCheck
        case checkAuthSession
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    try await Task.sleep(for: .seconds(1))
                    await send(.setUpRemoteConfig)
                }
            case .setUpRemoteConfig:
                return .run { send in
                    await splashUseCase.fetchAndActivate()
                    await send(.cachingRemoteConfig)
                }
            case .cachingRemoteConfig:
                let value = splashUseCase.getChallengeTabHideFlag(key: RemoteConfigKeys.challengeTabHideFlag.rawValue)
                TabBarManager.shared.isChallengeTabHidden = value
                return .send(.healthCheck)
            case .healthCheck:
                return .run { send in
                    await send(getHealthCheck())
                }
            case .serverHealthChecked(let isStable):
                if !isStable {
                    // TODO: Health 체크 실패 문구
                    state.isLoading = false
                    return .none
                }
                
                return .send(.checkAuthSession)
            case .checkAuthSession:
                guard let session = splashUseCase.getAuthSession() else {
                    state.isLoading = false
                    return .run { [router] _ in
                        await router(.routeToSignIn)
                    }
                }

                return .run { send in
                    await send(getUserInfo(session))
                }
            case .userInfoFetched(let session):
                state.isLoading = false
                let destination = makeNavigationDestination(from: session)

                return .run { [router] _ in
                    await router(destination)
                }
            case .userInfoFetchFailed:
                state.isLoading = false
                return .run { [router] _ in
                    await router(.routeToSignIn)
                }
            }
        }
    }
}

private extension SplashFeature {
    func makeNavigationDestination(from session: AuthSession) -> SplashRoute {
        guard session.personalInfoCompleted else {
            return .routeToOnBoarding
        }

        guard !session.mainAccessible else {
            return .routeToMain
        }

        return .routeToModyGroup(showSignUpDoneContents: !session.groupOnboardingCompleted)
    }

    func getHealthCheck() async -> Action {
        do {
            let isStable = try await splashUseCase.getHealthCheck()
            return .serverHealthChecked(isStable)
        } catch {
            return .serverHealthChecked(false)
        }
    }

    func getUserInfo(_ session: AuthSession) async -> Action {
        do {
            _ = try await authUseCase.getUserInfo()
            return .userInfoFetched(session)
        } catch {
            return .userInfoFetchFailed
        }
    }
}
