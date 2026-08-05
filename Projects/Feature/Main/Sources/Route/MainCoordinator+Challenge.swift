//
//  MainCoordinator+Challenge.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import ChallengeInterface
import CommonDomain

extension MainCoordinator: ChallengeRouter {
    public func route(from _: ChallengeRoute) {}
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
        }
    }
}
