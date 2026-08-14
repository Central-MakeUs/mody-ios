//
//  MainCoordinator+Challenge.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import ChallengeInterface
import CommonDomain

@MainActor
extension MainCoordinator: ChallengeRouter {
    public func route(from route: ChallengeRoute) {
        switch route {
        case let .routeToChallengeChange(groupId):
            let viewController = challengeBuilder.makeChallengeChangeViewController(
                groupId: groupId,
                router: self,
                outputHandler: self
            )
            navigationController.pushViewController(viewController, animated: true)
        case let .routeToWeeklyDetail(groupId, challengeId, groupChallengeId):
            let viewController = challengeBuilder.makeChallengeWeeklyDetailViewController(
                groupId: groupId,
                challengeId: challengeId,
                groupChallengeId: groupChallengeId,
                router: self,
                outputHandler: self
            )
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}

@MainActor
extension MainCoordinator: ChallengeChangeRouter {
    public func route(from route: ChallengeChangeRoute) {
        switch route {
        case .back:
            navigationController.popViewController(animated: true)
        }
    }
}

@MainActor
extension MainCoordinator: ChallengeWeeklyDetailRouter {
    public func route(from route: ChallengeWeeklyDetailRoute) {
        switch route {
        case .back:
            navigationController.popViewController(animated: true)
        }
    }
}

@MainActor
extension MainCoordinator: ChallengeOutputHandler {
    public func handle(output: ChallengeOutput) {
        switch output {
        case .nudgeStarted:
            mainContainerViewController?.setLoading(true)
        case let .nudgeSucceeded(nickname):
            mainContainerViewController?.showAlert(
                configuration: MainAlertConfiguration(
                    title: "콕 찌르기 완료",
                    contents: "\(nickname) 님을 콕 찔렀습니다!"
                )
            )
        case let .showAlert(error):
            let title: String
            let contents: String
            if case let .serverError(_, _, fallback) = error {
                title = fallback.title
                contents = fallback.message
            } else {
                title = error.title
                contents = error.message
            }

            mainContainerViewController?.showAlert(
                configuration: MainAlertConfiguration(
                    title: title,
                    contents: contents
                )
            )
        case .stepChallengeChanged:
            challengeInputHandler?.handle(input: .stepChallengeChanged)
        case .weeklyChallengeProofCreated:
            challengeInputHandler?.handle(input: .weeklyChallengeProofCreated)
        }
    }
}
