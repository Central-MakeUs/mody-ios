//
//  SplashFeature.swift
//  Splash
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture
import SplashInterface
import CommonDomain

@Reducer
public struct SplashFeature {
    private let splashUseCase: SplashUseCase
    private let router: @MainActor (SplashRoute) -> Void
    
    public init(
        splashUseCase: SplashUseCase,
        router: @escaping @MainActor (SplashRoute) -> Void
    ) {
        self.splashUseCase = splashUseCase
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case routeToSignIn
        case serverHealthChecked(Bool)
        case setUpRemoteConfig
        case cachingRemoteConfig
        case healthCheck
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
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
                print("value = \(value)")
                // TODO: 어디서 값 가지고 있어야 함.
                return .send(.healthCheck)
            case .healthCheck:
                return .run { send in
                    await send(getHealthCheck())
                }
            case .serverHealthChecked(let isStable):
                if isStable {
                    // TODO: Helath 체크 완료
                    return .send(.routeToSignIn)
                } else {
                    // TODO: Health 체크 실패 문구
                    return .none
                }
            case .routeToSignIn:
                return .run { [router] _ in
                    await router(.routeToSignIn)
                }
            }
        }
    }
}

private extension SplashFeature {
    func getHealthCheck() async -> Action {
        do {
            let isStable = try await splashUseCase.getHealthCheck()
            return .serverHealthChecked(isStable)
        } catch {
            return .serverHealthChecked(false)
        }
    }
}
