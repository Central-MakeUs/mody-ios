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
        case userInfoFetched(UserInfo)
        case userInfoFetchFailed
        case setUpRemoteConfig
        case cachingRemoteConfig
        case healthCheck
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
                
                return .run { send in
                    await send(getUserInfo())
                }
            case .userInfoFetched(let userInfo):
                state.isLoading = false
                let destination = makeNavigationDestination(from: userInfo)

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
    func makeNavigationDestination(from userInfo: UserInfo) -> SplashRoute {
        guard userInfo.personalInfoCompleted else {
            return .routeToOnBoarding
        }

        guard !userInfo.mainAccessible else {
            return .routeToMain
        }

        return .routeToModyGroup(showSignUpDoneContents: !userInfo.groupOnboardingCompleted)
    }

    func getHealthCheck() async -> Action {
        do {
            let isStable = try await splashUseCase.getHealthCheck()
            return .serverHealthChecked(isStable)
        } catch {
            return .serverHealthChecked(false)
        }
    }

    func getUserInfo() async -> Action {
        do {
            let userInfo = try await authUseCase.getUserInfo(needUpdateKeyChain: true)
            return .userInfoFetched(userInfo)
        } catch {
            return .userInfoFetchFailed
        }
    }
}
