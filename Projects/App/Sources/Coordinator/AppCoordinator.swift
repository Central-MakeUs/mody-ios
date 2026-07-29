//
//  AppCoordinator.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import UIKit
import Root
import MainInterface

final class AppCoordinator {
    let window: UIWindow
    let makeRootCoordinator: (RootCoordinatorDelegate) -> RootCoordinator
    let mainBuilder: MainBuildable

    var rootCoordinator: RootCoordinator?
    var mainCoordinator: MainCoordinating?

    init(
        window: UIWindow,
        makeRootCoordinator: @escaping (RootCoordinatorDelegate) -> RootCoordinator,
        mainBuilder: MainBuildable
    ) {
        self.window = window
        self.makeRootCoordinator = makeRootCoordinator
        self.mainBuilder = mainBuilder
    }

    @MainActor
    func start() {
        showRoot(animated: false)
    }
}
