//
//  SignInDemoDependencyContainer.swift
//  SignInDemo
//
//  Created by 김동준 on 10/1/26.
//

import CoreAuthTesting
import CommonDomain
import FirebaseServiceTesting
import SignIn
import SignInInterface

@MainActor
final class SignInDemoDependencyContainer {
    func makeSignInBuilder(for scenario: SignInScenario) -> SignInBuildable {
        SignInBuilder { router in
            SignInFeature(
                signInUseCase: SignInUseCase(
                    signInRepository: SignInRepository(
                        firebaseService: FirebaseServiceStub(
                            bools: [RemoteConfigKeys.guestLogin.rawValue: scenario.isDemoLoginEnabled]
                        )
                    )
                ),
                socialLoginUseCase: SocialLoginStub(
                    result: scenario.socialLoginResult,
                    responseDelay: .milliseconds(500)
                ),
                authUseCase: AuthUseCaseStub(
                    signIn: { _, _ in
                        try await Task.sleep(for: .milliseconds(500))
                        return try scenario.signInResult.get()
                    },
                    getUserInfo: { _ in try scenario.userInfoResult.get() }
                ),
                router: { route in
                    router.route(from: route)
                }
            )
        }
    }
}
