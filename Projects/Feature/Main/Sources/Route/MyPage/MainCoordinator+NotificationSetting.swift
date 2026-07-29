//
//  MainCoordinator+NotificationSetting.swift
//  Main
//
//  Created by 김동준 on 7/17/26
//

import MyPageInterface

@MainActor
extension MainCoordinator: MyPageNotificationSettingsRouter {
    public func route(from route: MyPageNotificationSettingsRoute) {
        switch route {
        case .back:
            navigationController.popViewController(animated: true)
        }
    }
}
