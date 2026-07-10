//
//  AppCoordinator.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import UIKit
import Root
import Main

final class AppCoordinator {
    let window: UIWindow
    let makeRootCoordinator: (RootCoordinatorDelegate) -> RootCoordinator
    let makeMainCoordinator: (MainCoordinatorDelegate) -> MainCoordinator

    var rootCoordinator: RootCoordinator?
    var mainCoordinator: MainCoordinator?

    init(
        window: UIWindow,
        makeRootCoordinator: @escaping (RootCoordinatorDelegate) -> RootCoordinator,
        makeMainCoordinator: @escaping (MainCoordinatorDelegate) -> MainCoordinator
    ) {
        self.window = window
        self.makeRootCoordinator = makeRootCoordinator
        self.makeMainCoordinator = makeMainCoordinator
    }

    @MainActor
    func start() {
        showRoot(animated: false)
    }
}
