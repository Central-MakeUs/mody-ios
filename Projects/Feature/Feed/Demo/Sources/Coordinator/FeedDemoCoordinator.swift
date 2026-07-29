//
//  FeedDemoCoordinator.swift
//  FeedDemo
//
//  Created by 김동준 on 7/22/26.
//

import FeedInterface
import CommonDomain
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
        let feedViewController = feedBuildable.makeFeedViewController(
            router: self,
            outputHandler: self
        )
        feedInputHandler = feedViewController as? FeedInputHandler
        let mainContainerViewController = FeedDemoMainContainerViewController(
            feedViewController: feedViewController
        )

        navigationController.setViewControllers([mainContainerViewController], animated: false)
        navigationController.navigationBar.isHidden = true
        return navigationController
    }
}

extension FeedDemoCoordinator: FeedOutputHandler {
    func handle(output: FeedOutput) {
        switch output {
        case let .reportConfirmationRequested(recordId):
            let alert = UIAlertController(
                title: "게시물을 신고하시겠어요?",
                message: "신고한 게시물은 검토 후 삭제 처리할 예정입니다.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.addAction(UIAlertAction(title: "신고하기", style: .default) { [weak self] _ in
                self?.feedInputHandler?.handle(
                    input: .reportConfirmed(recordId: recordId)
                )
            })
            navigationController.present(alert, animated: true)
        case .reportSucceeded:
            presentReportResultAlert(
                title: "신고가 완료되었어요",
                message: "검토 및 처리는 최대 7일까지 걸릴 수 있어요."
            )
        case let .reportFailed(error):
            let title: String
            let message: String
            if case let .serverError(_, _, fallback) = error {
                title = fallback.title
                message = fallback.message
            } else {
                title = error.title
                message = error.message
            }
            presentReportResultAlert(title: title, message: message)
        }
    }

    private func presentReportResultAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        navigationController.present(alert, animated: true)
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
