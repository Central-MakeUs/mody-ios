//
//  AppCoordinator.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import UIKit
import Root

final class AppCoordinator {
    let window: UIWindow
    let makeRootCoordinator: (RootCoordinatorDelegate) -> RootCoordinator

    var rootCoordinator: RootCoordinator?

    init(
        window: UIWindow,
        makeRootCoordinator: @escaping (RootCoordinatorDelegate) -> RootCoordinator
    ) {
        self.window = window
        self.makeRootCoordinator = makeRootCoordinator
    }

    @MainActor
    func start() {
        showRoot(animated: false)
    }
}
