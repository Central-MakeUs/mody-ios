//
//  AppAssembly.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Swinject

struct AppAssembly: Assembly {
    func assemble(container: Container) {
        assembleFirebaseService(in: container)
        assembleCoreNetwork(in: container)
        assembleCoreKakao(in: container)
        assembleCoreAuth(in: container)
        assembleCoreModyImage(in: container)
        assembleCoreCamera(in: container)
        assembleCoreNotification(in: container)
        assembleFeature(in: container)
        assembleRoot(in: container)
        assembleMain(in: container)
        assembleApp(in: container)
    }
    
    private func assembleFeature(in container: Container) {
        assembleSplashFeature(in: container)
        assembleSignInFeature(in: container)
        assembleOnBoardingFeature(in: container)
        assembleModyGroupFeature(in: container)
        assembleFeedRecordReactor(in: container)
        assembleFeedReactor(in: container)
        assembleChallengeFeature(in: container)
        assembleMyPageFeatures(in: container)
    }
    
    private func assembleMyPageFeatures(in container: Container) {
        assembleMyPageProfileFeature(in: container)
        assembleMyPageSettingsFeatures(in: container)
        assembleMyPageFeature(in: container)
    }
    
    private func assembleMyPageSettingsFeatures(in container: Container) {
        assembleMyPageNotificationSettingsFeatures(in: container)
        assembleMyPageGroupSettingsFeatures(in: container)
        assembleMyPageHealthDataSettingsFeatures(in: container)
    }
}
