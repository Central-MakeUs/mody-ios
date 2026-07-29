//
//  AppAssembly+CoreAuth.swift
//  Mody
//
//  Created by 김동준 on 7/2/26
//

import CoreAuth
import CoreAuthInterface
import CoreKakaoInterface
import CoreKeyChainStorage
import CoreNetworkInterface
import Swinject

extension AppAssembly {
    func assembleCoreAuth(in container: Container) {
        container.register(AuthService.self) { resolver in
            let network: CoreNetworkProtocol = resolver.resolve()

            return AuthService(network: network)
        }

        container.register(AuthRepositoryProtocol.self) { resolver in
            let authService: AuthService = resolver.resolve()

            return AuthRepository(
                authService: authService,
                keyChainStorage: CoreKeyChainStorage()
            )
        }

        container.register(AuthUseCaseProtocol.self) { resolver in
            let authRepository: AuthRepositoryProtocol = resolver.resolve()

            return AuthUseCase(authRepository: authRepository)
        }

        container.register(SocialLoginInterface.self) { resolver in
            let kakaoAuthService: CoreKakaoAuthInterface = resolver.resolve()

            return SocialLoginService(kakaoAuthService: kakaoAuthService)
        }
    }
}
