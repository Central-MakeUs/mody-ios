//
//  MainCoordinator+MyPage.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import MyPageInterface

@MainActor
extension MainCoordinator: MyPageRouter {
    public func route(from route: MyPageRoute) {
        switch route {
        case .routeToProfile:
            let viewController = myPageBuilder.makeProfileViewController(router: self)
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}
