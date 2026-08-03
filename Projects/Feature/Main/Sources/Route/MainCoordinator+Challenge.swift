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
