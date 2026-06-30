//
//  AppAssembly.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Swinject

struct AppAssembly: Assembly {
    func assemble(container: Container) {
        assembleFeature(in: container)
        assembleRoot(in: container)
        assembleMain(in: container)
        assembleApp(in: container)
    }
    
    private func assembleFeature(in container: Container) {
        assembleSplashFeature(in: container)
        assembleSignInFeature(in: container)
        assembleOnBoardingFeature(in: container)
        assembleSignUpDoneFeature(in: container)
        assembleFeedReactor(in: container)
        assembleChallengeFeature(in: container)
        assembleMyPageFeature(in: container)
    }
}
