//
//  AppDependencyContainer.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import UIKit
import CoreNotificationInterface
import Swinject

final class AppDependencyContainer {
    private let assembler: Assembler

    init() {
        assembler = Assembler([
            AppAssembly()
        ])
    }

    func makeAppCoordinator(window: UIWindow) -> AppCoordinator {
        assembler.resolver.resolve(argument: window)
    }

    func makeNotificationUseCase() -> NotificationUseCaseProtocol {
        assembler.resolver.resolve()
    }
}
