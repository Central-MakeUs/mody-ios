//
//  MainInterface.swift
//  MainInterface
//
//  Created by 김동준 on 7/24/26.
//

import UIKit

public protocol MainBuildable {
    @MainActor
    func makeMainCoordinator(delegate: MainCoordinatorDelegate) -> MainCoordinating
}

public protocol MainCoordinating: AnyObject {
    var navigationController: UINavigationController { get }

    @MainActor
    func start()
}
