//
//  AppDelegate.swift
//  Mody
//
//  Created by 김동준 on 6/23/26.

import UIKit
import DesignSystem
import FirebaseCore
import KakaoSDKCommon

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
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
        configureKakaoSDK()
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
}
