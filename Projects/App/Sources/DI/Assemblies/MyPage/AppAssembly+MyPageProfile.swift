//
//  AppAssembly+MyPageProfile.swift
//  Mody
//
//  Created by 김동준 on 7/12/26.
//

import Swinject
import CoreAuthInterface
import CoreModyImageInterface
import MyPageInterface
import MyPage

extension AppAssembly {
    func assembleMyPageProfileFeature(in container: Container) {
        container.register(ProfileFeature.self) { (
            resolver: Resolver,
            arguments: (MyPageProfileRouter, MyPageOutputHandler)
        ) in
            let (router, outputHandler) = arguments
            let authUseCase: AuthUseCaseProtocol = resolver.resolve()
            let myPageUseCase: MyPageUseCase = resolver.resolve()
            let imageUploadUseCase: ImageUploadUseCaseProtocol = resolver.resolve()
            let temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol = resolver.resolve()

            return ProfileFeature(
                authUseCase: authUseCase,
                myPageUseCase: myPageUseCase,
                imageUploadUseCase: imageUploadUseCase,
                temporaryImageFileUseCase: temporaryImageFileUseCase,
                router: { [weak router] route in
                    router?.route(from: route)
                },
                output: { [weak outputHandler] output in
                    outputHandler?.handle(output: output)
                }
            )
        }
    }
}
