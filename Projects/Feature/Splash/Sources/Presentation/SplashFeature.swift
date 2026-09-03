//
//  SplashFeature.swift
//  Splash
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture
import SplashInterface
import CommonDomain
import CoreAnalyticsInterface
import CoreAuthInterface
import Foundation
import Base

@Reducer
public struct SplashFeature {
    private let splashUseCase: SplashUseCase
    private let authUseCase: AuthUseCaseProtocol
    private let analyticsUseCase: AnalyticsUseCaseProtocol
    private let router: @MainActor (SplashRoute) -> Void
    
    public init(
        splashUseCase: SplashUseCase,
        authUseCase: AuthUseCaseProtocol,
        analyticsUseCase: AnalyticsUseCaseProtocol,
        router: @escaping @MainActor (SplashRoute) -> Void
    ) {
        self.splashUseCase = splashUseCase
        self.authUseCase = authUseCase
        self.analyticsUseCase = analyticsUseCase
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public enum AlertCase: Equatable {
            case error(NetworkError)
            case forceUpdate
            case minimumSupportedVersion
            case notice(NoticePopupInfo)
        }

        public init() {
            self.currentAppVersion = Bundle.main.object(
                forInfoDictionaryKey: "CFBundleShortVersionString"
            ) as? String ?? ""
        }
        
        var isLoading = true
        let currentAppVersion: String
        var appStoreURLString = ""
        var alertCase: AlertCase?
        var alertState = AlertFeature.State(dismissOnScrimTap: false)
    }
    
    public enum Action {
        case onAppear
        case serverHealthChecked(Bool)
        case userInfoFetched(UserInfo)
        case userInfoFetchFailed
        case setUpRemoteConfig
        case checkForceUpdate
        case checkMinimumSupportedVersion
        case checkNotice
        case alertAction(AlertFeature.Action)
        case showAlert(State.AlertCase)
        case noticeConfirmButtonTapped
        case healthCheck
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.alertState, action: \.alertAction) {
            AlertFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await send(.setUpRemoteConfig)
                }
            case .setUpRemoteConfig:
                return .run { send in
                    await splashUseCase.fetchAndActivate()
                    await send(.checkForceUpdate)
                }
            case .checkForceUpdate:
                let needForceUpdate = splashUseCase.getRemoteConfigBool(for: .forceUpdate)

                if needForceUpdate {
                    state.appStoreURLString = splashUseCase.getRemoteConfigString(for: .appStoreURL)
                    return .send(.showAlert(.forceUpdate))
                }
                
                return .send(.checkMinimumSupportedVersion)
            case .checkMinimumSupportedVersion:
                let targetVersion = splashUseCase.getRemoteConfigString(for: .minimumSupportedVersion)
                
                let needsMinimumVersionUpdate = splashUseCase.needsMinimumVersionUpdate(
                    currentVersion: state.currentAppVersion,
                    targetVersion: targetVersion
                )

                if needsMinimumVersionUpdate {
                    state.appStoreURLString = splashUseCase.getRemoteConfigString(for: .appStoreURL)
                    return .send(.showAlert(.minimumSupportedVersion))
                }
                
                return .send(.checkNotice)
            case .checkNotice:
                let noticePopupInfo = splashUseCase.getNoticePopupInfo()

                guard let noticePopupInfo,
                      !noticePopupInfo.isEmpty else {
                    return .send(.healthCheck)
                }

                return .send(.showAlert(.notice(noticePopupInfo)))
            case .alertAction:
                return .none
            case let .showAlert(alertCase):
                state.isLoading = false
                state.alertCase = alertCase
                return .send(.alertAction(.present))
            case .noticeConfirmButtonTapped:
                guard case let .notice(noticePopupInfo) = state.alertCase,
                      noticePopupInfo.skipPossible == true else {
                    return .none
                }

                return .run { send in
                    await send(.alertAction(.dismiss))
                    await send(.healthCheck)
                }
            case .healthCheck:
                state.isLoading = true
                return .run { send in
                    await send(getHealthCheck())
                }
            case .serverHealthChecked(let isStable):
                if !isStable {
                    return .send(.showAlert(.error(.unknown)))
                }
                
                return .run { send in
                    await send(getUserInfo())
                }
            case .userInfoFetched(let userInfo):
                state.isLoading = false
                let destination = makeNavigationDestination(from: userInfo)

                return .run { [analyticsUseCase, router] _ in
                    analyticsUseCase.setUserID(String(userInfo.memberId))
                    analyticsUseCase.setUserNickname(userInfo.nickname)
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
            return .showAlert(.error(error as? NetworkError ?? .unknown))
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
