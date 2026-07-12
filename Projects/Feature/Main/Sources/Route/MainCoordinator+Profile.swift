//
//  MainCoordinator+Profile.swift
//  Main
//
//  Created by 김동준 on 7/12/26.
//

import MyPageInterface

@MainActor
extension MainCoordinator: MyPageProfileRouter {
    public func route(from route: MyPageProfileRoute) {
        switch route {
        case .back:
            navigationController.popViewController(animated: true)
        case .routeToSignIn:
            delegate?.didRequestLogout(self)
        }
    }
}
