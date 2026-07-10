//
//  SignInFeature.swift
//  SignIn
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture
import CommonDomain
import CoreAuthInterface
import SignInInterface
import ModyLogger

@Reducer
public struct SignInFeature {
    private let socialLoginUseCase: SocialLoginInterface
    private let authUseCase: AuthUseCaseProtocol
    private let router: @MainActor (SignInRoute) -> Void
    
    public init(
        socialLoginUseCase: SocialLoginInterface,
        authUseCase: AuthUseCaseProtocol,
        router: @escaping @MainActor (SignInRoute) -> Void
    ) {
        self.socialLoginUseCase = socialLoginUseCase
        self.authUseCase = authUseCase
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        var isLoading: Bool = false
        var loginType: SocialLoginType?
        var navigationDestination: SignInRoute?
        
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case mainButtonTapped
        case onBoardingButtonTapped
        case kakaoLoginButtonTapped
        case receiveLoginSessionSuccessfully(AuthSession)
        case kakaoLoginError
        case appleLoginButtonTapped
        case appleLoginError
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .mainButtonTapped:
                return .run { [router] _ in
                    await router(.routeToMain)
                }
            case .onBoardingButtonTapped:
                return .run { [router] _ in
                    await router(.routeToOnBoarding)
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
                    await router(destination)
                }
            case .kakaoLoginError:
                state.isLoading = false
                return .none
            case .appleLoginError:
                state.isLoading = false
                return .none
            }
        }
    }
}

private extension SignInFeature {
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
                return .kakaoLoginError
            }

            let session = try await authUseCase.signIn(
                loginType: .kakao,
                accessToken: accessToken
            )

            return .receiveLoginSessionSuccessfully(session)
        } catch {
            ModyLogger.debug("Kakao login failed: \(error)")
            return .kakaoLoginError
        }
    }

    func signInWithApple() async -> Action {
        do {
            guard let accessToken = try await socialLoginUseCase.signInWithApple() else {
                return .appleLoginError
            }

            let session = try await authUseCase.signIn(
                loginType: .apple,
                accessToken: accessToken
            )

            return .receiveLoginSessionSuccessfully(session)
        } catch {
            ModyLogger.debug("Apple login failed: \(error)")
            return .appleLoginError
        }
    }
}
