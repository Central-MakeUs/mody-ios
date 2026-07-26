//
//  FeedDemoCoordinator.swift
//  FeedDemo
//
//  Created by 김동준 on 7/22/26.
//

import FeedInterface
import UIKit

@MainActor
final class FeedDemoCoordinator: ObservableObject {
    private let dependencyContainer: FeedDemoDependencyContainer
    private lazy var feedBuildable = dependencyContainer.makeFeedBuildable()
    private let navigationController = UINavigationController()
    private weak var feedInputHandler: FeedInputHandler?

    init(dependencyContainer: FeedDemoDependencyContainer = FeedDemoDependencyContainer()) {
        self.dependencyContainer = dependencyContainer
    }

    func makeRootViewController() -> UINavigationController {
        let feedViewController = feedBuildable.makeFeedViewController(router: self)
        feedInputHandler = feedViewController as? FeedInputHandler
        let mainContainerViewController = FeedDemoMainContainerViewController(
            feedViewController: feedViewController
        )

        navigationController.setViewControllers([mainContainerViewController], animated: false)
        navigationController.navigationBar.isHidden = true
        return navigationController
    }
}

extension FeedDemoCoordinator: FeedRouter {
    func route(from route: FeedRoute) {
        switch route {
        case .addGroup:
            let alert = UIAlertController(
                title: "FeedDemo",
                message: "그룹 추가는 Demo에서 mock 처리됩니다.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            navigationController.present(alert, animated: true)
        case let .routeToRecord(recordType):
            let viewController = feedBuildable.makeFeedRecordViewController(
                router: self,
                recordType: recordType,
                outputHandler: self
            )
            viewController.hidesBottomBarWhenPushed = true
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}

extension FeedDemoCoordinator: FeedRecordRouter {
    func route(from route: FeedRecordRoute) {
        switch route {
        case .back:
            navigationController.popViewController(animated: true)
        }
    }
}

extension FeedDemoCoordinator: FeedRecordOutputHandler {
    func handle(output: FeedRecordOutput) {
        switch output {
        case .recordCreated:
            navigationController.popViewController(animated: true)

            guard let coordinator = navigationController.transitionCoordinator else {
                feedInputHandler?.handle(input: .recordCreated)
                return
            }

            coordinator.animate(alongsideTransition: nil) { [weak self] _ in
                self?.feedInputHandler?.handle(input: .recordCreated)
            }
        }
    }
}
