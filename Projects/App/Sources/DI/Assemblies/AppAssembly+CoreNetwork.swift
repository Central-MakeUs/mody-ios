//
//  AppAssembly+CoreNetwork.swift
//  Mody
//
//  Created by 김동준 on 7/2/26
//

import CoreNetwork
import CoreKeyChainStorage
import CoreKeyChainStorageInterface
import CoreNetworkInterface
import Swinject

extension AppAssembly {
    func assembleCoreNetwork(in container: Container) {
        container.register(CoreTokenStorage.self) { _ in
            TokenStorageAdapter(keyChainStorage: CoreKeyChainStorage())
        }
        .inObjectScope(.container)

        container.register(CoreNetworkProtocol.self) { resolver in
            let tokenStorage: CoreTokenStorage = resolver.resolve()

            return CoreNetworkClient(
                tokenStore: tokenStorage,
                refreshTokenEndpoint: CoreNetworkEndpoint(
                    path: "api/v1/auth/reissue",
                    method: .POST,
                    requiresAuthorization: false
                )
            )
        }
        .inObjectScope(.container)
    }
}
