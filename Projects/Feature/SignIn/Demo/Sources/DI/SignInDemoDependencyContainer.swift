//
//  SignInDemoDependencyContainer.swift
//  SignInDemo
//
//  Created by 김동준 on 10/1/26.
//

import SignIn
import SignInInterface
import SignInTesting

@MainActor
final class SignInDemoDependencyContainer {
    func makeSignInBuilder(for scenario: SignInScenario) -> SignInBuildable {
        SignInBuilder { router in
            SignInFeature(
                signInUseCase: SignInUseCase(
                    signInRepository: SignInDemoRepositoryStub(
                        isDemoLoginEnabled: scenario.isDemoLoginEnabled
                    )
                ),
                socialLoginUseCase: SignInSocialLoginStub(
                    result: scenario.socialLoginResult,
                    responseDelay: .milliseconds(500)
                ),
                authUseCase: SignInAuthUseCaseStub(
                    signInResult: scenario.signInResult,
                    userInfoResult: scenario.userInfoResult,
                    responseDelay: .milliseconds(500)
                ),
                analyticsUseCase: SignInAnalyticsUseCaseStub(),
                router: { route in
                    router.route(from: route)
                }
            )
        }
    }
}
