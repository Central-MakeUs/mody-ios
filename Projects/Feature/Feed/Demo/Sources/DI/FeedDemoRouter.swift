//
//  FeedDemoRouter.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

import FeedInterface
import UIKit

@MainActor
final class FeedDemoRouter: FeedRouter, FeedRecordRouter {
    private let onRoute: (String) -> Void
    private var builder: FeedBuildable?
    private weak var navigationController: UINavigationController?
    private weak var outputHandler: FeedDemoOutputHandler?
    private weak var feedInputHandler: FeedInputHandler?

    init(onRoute: @escaping (String) -> Void) {
        self.onRoute = onRoute
    }

    func attach(
        builder: FeedBuildable,
        navigationController: UINavigationController,
        outputHandler: FeedDemoOutputHandler
    ) {
        self.builder = builder
        self.navigationController = navigationController
        self.outputHandler = outputHandler
        feedInputHandler = nil
    }

    func setFeedInput(_ input: FeedInputHandler?) {
        feedInputHandler = input
    }

    func route(from route: FeedRoute) {
        switch route {
        case .addGroup:
            onRoute("그룹 추가 요청")
            outputHandler?.presentAlert(title: "그룹 추가 요청", message: "Feed의 그룹 추가 route가 호출됐습니다.")
        case .routeToChallenge:
            onRoute("챌린지 이동 요청")
            outputHandler?.presentAlert(title: "챌린지 이동 요청", message: "Feed의 챌린지 route가 호출됐습니다.")
        case let .routeToRecord(recordType):
            onRoute("\(recordType.title) 진입")
            guard let builder, let outputHandler else { return }
            let viewController = builder.makeFeedRecordViewController(
                router: self,
                recordType: recordType,
                outputHandler: outputHandler
            )
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func route(from route: FeedRecordRoute) {
        switch route {
        case .back:
            onRoute("기록 작성 취소 · 피드 복귀")
            navigationController?.popViewController(animated: true)
        }
    }

    func sendFeedInput(_ input: FeedInput) {
        feedInputHandler?.handle(input: input)
    }

    func recordCreated() {
        navigationController?.popViewController(animated: true)
        if let transition = navigationController?.transitionCoordinator {
            transition.animate(alongsideTransition: nil) { [weak self] _ in
                self?.sendFeedInput(.recordCreated)
            }
        } else {
            sendFeedInput(.recordCreated)
        }
    }
}
