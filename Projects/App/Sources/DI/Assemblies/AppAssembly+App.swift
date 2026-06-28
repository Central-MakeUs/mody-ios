//
//  AppAssembly+App.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Swinject
import UIKit

extension AppAssembly {
    func assembleApp(in container: Container) {
        container.register(AppCoordinator.self) { (resolver: Resolver, window: UIWindow) in
            AppCoordinator(
                window: window,
                makeRootCoordinator: { delegate in
                    resolver.resolve(argument: delegate)
                }
            )
        }
    }
}
