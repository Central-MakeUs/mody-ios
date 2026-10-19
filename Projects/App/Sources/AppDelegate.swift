//
//  AppDelegate.swift
//  Mody
//
//  Created by 김동준 on 6/23/26.

import UIKit
import CoreModyImageInterface
import CoreNotificationInterface
import DesignSystem
import FirebaseCore
import FirebaseMessaging
import KakaoSDKCommon
import ModyLogger

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    let appDependencyContainer = AppDependencyContainer()
    lazy var notificationUseCase = appDependencyContainer.makeNotificationUseCase()
    lazy var temporaryImageFileUseCase = appDependencyContainer.makeTemporaryImageFileUseCase()

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        DesignSystemFontFamily.registerAllCustomFonts()
        FirebaseApp.configure()
        configureNotifications(application)
        configureKakaoSDK()
        do {
            try temporaryImageFileUseCase.removeExpiredImages(olderThan: 24 * 60 * 60)
        } catch {
            ModyLogger.error("[TemporaryImage] cleanup failed: \(error)")
        }
        return true
    }
}

private extension AppDelegate {
    func configureKakaoSDK() {
        guard let appKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else {
            return
        }

        KakaoSDK.initSDK(appKey: appKey)
    }

    func configureNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self

        let messaging = Messaging.messaging()
        messaging.delegate = self
        messaging.isAutoInitEnabled = true

        ModyLogger.debug("[FCM] auto init:, \(messaging.isAutoInitEnabled)")
        application.registerForRemoteNotifications()
    }
}
