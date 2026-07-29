//
//  MainCoordinator+HealthDataSetting.swift
//  Main
//
//  Created by 김동준 on 7/17/26
//

import MyPageInterface

@MainActor
extension MainCoordinator: MyPageHealthDataSettingsRouter {
    public func route(from route: MyPageHealthDataSettingsRoute) {
        switch route {
        case .back:
            navigationController.popViewController(animated: true)
        }
    }
}
