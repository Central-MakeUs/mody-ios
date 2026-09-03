//
//  SignInFeature.swift
//  SignIn
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture
import Base
import CommonDomain
import CoreAnalyticsInterface
import CoreAuthInterface
import SignInInterface
import ModyLogger

@Reducer
public struct SignInFeature {
    private let signInUseCase: SignInUseCase
    private let socialLoginUseCase: SocialLoginInterface
    private let authUseCase: AuthUseCaseProtocol
    private let analyticsUseCase: AnalyticsUseCaseProtocol
    private let router: @MainActor (SignInRoute) -> Void
    
    public init(
        signInUseCase: SignInUseCase,
        socialLoginUseCase: SocialLoginInterface,
        authUseCase: AuthUseCaseProtocol,
        analyticsUseCase: AnalyticsUseCaseProtocol,
        router: @escaping @MainActor (SignInRoute) -> Void
    ) {
        self.signInUseCase = signInUseCase
        self.socialLoginUseCase = socialLoginUseCase
        self.authUseCase = authUseCase
        self.analyticsUseCase = analyticsUseCase
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public enum AlertCase: Equatable {
            case error(NetworkError)
        }

        var isLoading: Bool = false
        var loginType: SocialLoginType?
        var navigationDestination: SignInRoute?
        var alertCase: AlertCase?
        var alertState = AlertFeature.State()
        
        var demoLoginTapCount = 0
        var demoLoginPassword = ""
        var isDemoLoginAlertPresented = false
        var isDemoLoginEnabled = false
        let demoLoginTapThreshold = 20
        
        public init() {}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case alertAction(AlertFeature.Action)
        case showAlert(State.AlertCase)
        case onAppear
        case demoLoginTriggerAreaTapped
        case demoLoginCancelButtonTapped
        case demoLoginConfirmButtonTapped
        case demoLoginError(NetworkError)
        case kakaoLoginButtonTapped
        case receiveLoginSessionSuccessfully(AuthSession)
        case kakaoLoginError(NetworkError)
        case appleLoginButtonTapped
        case appleLoginError(NetworkError)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.alertState, action: \.alertAction) {
            AlertFeature()
        }

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .alertAction:
                return .none
            case let .showAlert(alertCase):
                state.isLoading = false
                state.alertCase = alertCase
                return .send(.alertAction(.present))
            case .onAppear:
                state.isDemoLoginEnabled = signInUseCase.isDemoLoginEnabled()
                return .none
            case .demoLoginTriggerAreaTapped:
                guard state.isDemoLoginEnabled, !state.isLoading else {
                    return .none
                }

                state.demoLoginTapCount += 1

                guard state.demoLoginTapCount >= state.demoLoginTapThreshold else {
                    return .none
                }

                state.demoLoginTapCount = 0
                state.demoLoginPassword = ""
                state.isDemoLoginAlertPresented = true
                return .none
            case .demoLoginCancelButtonTapped:
                resetDemoLoginState(&state)
                return .none
            case .demoLoginConfirmButtonTapped:
                guard state.isDemoLoginEnabled,
                      state.demoLoginPassword == "77777",
                      !state.isLoading else {
                    resetDemoLoginState(&state)
                    return .none
                }

                resetDemoLoginState(&state)
                state.isLoading = true
                return .run { send in
                    await send(signInWithDemo())
                }
            case .kakaoLoginButtonTapped:
                state.isLoading = true
                return .run { send in
                    await send(signInWithKakao())
                }
            case .appleLoginButtonTapped:
                state.isLoading = true
                return .run { send in
                    await send(signInWithApple())
                }
            case .receiveLoginSessionSuccessfully(let session):
                state.isLoading = false
                let destination = makeNavigationDestination(from: session)
                state.navigationDestination = destination

                return .run { [router] _ in
                    analyticsUseCase.setUserID(String(session.id))

                    if session.personalInfoCompleted,
                       let userInfo = try? await authUseCase.getUserInfo(needUpdateKeyChain: false) {

                        if !userInfo.nickname.isEmpty {
                            analyticsUseCase.setUserNickname(userInfo.nickname)
                        }
                    }

                    await router(destination)
                }
            case let .kakaoLoginError(error),
                 let .appleLoginError(error),
                 let .demoLoginError(error):
                return .send(.showAlert(.error(error)))
            }
        }
    }
}

private extension SignInFeature {
    func resetDemoLoginState(_ state: inout State) {
        state.demoLoginTapCount = 0
        state.demoLoginPassword = ""
        state.isDemoLoginAlertPresented = false
    }

    func makeNavigationDestination(from session: AuthSession) -> SignInRoute {
        guard session.personalInfoCompleted else {
            return .routeToOnBoarding
        }
        
        guard !session.mainAccessible else {
            return .routeToMain
        }
        
        return .routeToModyGroup(showSignUpDoneContents: !session.groupOnboardingCompleted)
    }
    
    func signInWithKakao() async -> Action {
        do {
            guard let accessToken = try await socialLoginUseCase.signInWithKakao() else {
                return .kakaoLoginError(.unknown)
            }

            let session = try await authUseCase.signIn(
                loginType: .kakao,
                accessToken: accessToken
            )

            return .receiveLoginSessionSuccessfully(session)
        } catch {
            ModyLogger.debug("Kakao login failed: \(error)")
            return .kakaoLoginError(error as? NetworkError ?? .unknown)
        }
    }

    func signInWithApple() async -> Action {
        do {
            guard let accessToken = try await socialLoginUseCase.signInWithApple() else {
                return .appleLoginError(.unknown)
            }

            let session = try await authUseCase.signIn(
                loginType: .apple,
                accessToken: accessToken
            )

            return .receiveLoginSessionSuccessfully(session)
        } catch {
            ModyLogger.debug("Apple login failed: \(error)")
            return .appleLoginError(error as? NetworkError ?? .unknown)
        }
    }

    func signInWithDemo() async -> Action {
        do {
            let session = try await authUseCase.signIn(
                loginType: .iosTest,
                accessToken: ""
            )

            return .receiveLoginSessionSuccessfully(session)
        } catch {
            ModyLogger.debug("Demo login failed: \(error)")
            return .demoLoginError(error as? NetworkError ?? .unknown)
        }
    }
}
