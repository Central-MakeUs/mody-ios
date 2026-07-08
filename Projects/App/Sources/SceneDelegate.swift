//
//  SceneDelegate.swift
//  Mody
//
//  Created by 김동준 on 6/23/26.
//

import UIKit
import KakaoSDKAuth

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appDependencyContainer: AppDependencyContainer?
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let appDependencyContainer = AppDependencyContainer()
        let appCoordinator = appDependencyContainer.makeAppCoordinator(window: window)

        self.window = window
        self.appDependencyContainer = appDependencyContainer
        self.appCoordinator = appCoordinator

        appCoordinator.start()
        window.makeKeyAndVisible()
        window.addKeyboardDismissTapGestureRecognizer()
    }
    
    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
}
