//
//  MainCoordinator+MyPage.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import MyPageInterface
import CommonDomain

@MainActor
extension MainCoordinator: MyPageRouter {
    public func route(from route: MyPageRoute) {
        switch route {
        case let .routeToProfile(profileImageURL, defaultAvatar):
            let viewController = myPageBuilder.makeProfileViewController(
                profileImageURL: profileImageURL,
                defaultAvatar: defaultAvatar,
                router: self,
                outputHandler: self
            )
            navigationController.pushViewController(viewController, animated: true)
        case .routeToNotificationSettings:
            let viewController = myPageBuilder.makeNotificationSettingsViewController(router: self)
            navigationController.pushViewController(viewController, animated: true)
        case .routeToGroupSettings:
            let viewController = myPageBuilder.makeGroupSettingsViewController(router: self)
            navigationController.pushViewController(viewController, animated: true)
        case .routeToHealthDataSettings:
            let viewController = myPageBuilder.makeHealthDataSettingsViewController(router: self)
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}

@MainActor
extension MainCoordinator: MyPageOutputHandler {
    public func handle(output: MyPageOutput) {
        switch output {
        case .weightRecordStarted:
            mainContainerViewController?.setLoading(true)
        case .weightRecordSucceeded:
            mainContainerViewController?.showAlert(
                configuration: MainAlertConfiguration(
                    title: "기록 완료",
                    contents: "체중 기록이 완료되었어요."
                )
            )
        case let .weightRecordFailed(error):
            mainContainerViewController?.showAlert(
                configuration: MainAlertConfiguration(
                    title: error.title,
                    contents: error.message
                )
            )
        case .profileUpdated:
            myPageInputHandler?.handle(input: .profileUpdated)
        }
    }
}
