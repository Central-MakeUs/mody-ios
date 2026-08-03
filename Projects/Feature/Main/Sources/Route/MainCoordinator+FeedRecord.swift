//
//  MainCoordinator+FeedRecord.swift
//  Main
//
//  Created by 김동준 on 7/12/26
//

import FeedInterface
import UIKit

extension MainCoordinator: FeedRecordRouter {
    public func route(from route: FeedRecordRoute) {
        switch route {
        case .back:
            navigationController.popViewController(animated: true)
        }
    }
}

extension MainCoordinator: FeedRecordOutputHandler {
    public func handle(output: FeedRecordOutput) {
        switch output {
        case .recordCreated:
            navigationController.popViewController(animated: true)

            if let transitionCoordinator = navigationController.transitionCoordinator {
                transitionCoordinator.animate(alongsideTransition: nil) { [weak self] _ in
                    self?.feedInputHandler?.handle(input: .recordCreated)
                    self?.challengeInputHandler?.handle(input: .recordUpdated)
                }
            } else {
                Task { @MainActor [weak self] in
                    self?.feedInputHandler?.handle(input: .recordCreated)
                    self?.challengeInputHandler?.handle(input: .recordUpdated)
                }
            }
        }
    }
}
