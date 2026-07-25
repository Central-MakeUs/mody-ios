//
//  AppAssembly+MyPage.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import CoreAuthInterface
import CoreModyImageInterface
import CoreNetworkInterface
import MyPageInterface
import MyPage

extension AppAssembly {
    func assembleMyPageFeature(in container: Container) {
        container.register(MyPageRepositoryProtocol.self) { resolver in
            let network: CoreNetworkProtocol = resolver.resolve()

            return MyPageRepository(network: network)
        }

        container.register(MyPageUseCase.self) { resolver in
            let myPageRepository: MyPageRepositoryProtocol = resolver.resolve()

            return MyPageUseCase(myPageRepository: myPageRepository)
        }

        container.register(MyPageFeature.self) { (
            resolver: Resolver,
            arguments: (MyPageRouter, MyPageOutputHandler)
        ) in
            let (router, outputHandler) = arguments
            let authUseCase: AuthUseCaseProtocol = resolver.resolve()
            let myPageUseCase: MyPageUseCase = resolver.resolve()

            return MyPageFeature(
                authUseCase: authUseCase,
                myPageUseCase: myPageUseCase,
                router: { [weak router] route in
                    router?.route(from: route)
                },
                output: { [weak outputHandler] output in
                    outputHandler?.handle(output: output)
                }
            )
        }

        container.register(MyPageBuildable.self) { resolver in
            let imageLoader: RemoteImageLoading = resolver.resolve()

            return MyPageBuilder(
                makeMyPageFeature: { router, outputHandler in
                    resolver.resolve(argument: (router, outputHandler))
                },
                makeProfileFeature: { router, outputHandler in
                    resolver.resolve(argument: (router, outputHandler))
                },
                makeNotificationSettingsFeature: { router in
                    resolver.resolve(argument: router)
                },
                makeGroupSettingsFeature: { router, outputHandler in
                    resolver.resolve(argument: (router, outputHandler))
                },
                makeHealthDataSettingsFeature: { router in
                    resolver.resolve(argument: router)
                },
                imageLoader: imageLoader
            )
        }
    }
}
