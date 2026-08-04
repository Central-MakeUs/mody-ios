//
//  MainCoordinator+Feed.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import CommonDomain
import DesignSystem
import FeedInterface

extension MainCoordinator: FeedRouter {
    public func route(from route: FeedRoute) {
        switch route {
        case .addGroup:
            mainContainerViewController?.presentAddGroupAlert()
        case .routeToRecord(let recordType):
            let viewController = feedBuilder.makeFeedRecordViewController(
                router: self,
                recordType: recordType,
                outputHandler: self
            )
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}

@MainActor
extension MainCoordinator: FeedOutputHandler {
    public func handle(output: FeedOutput) {
        switch output {
        case let .selectedGroupUpdated(group):
            challengeInputHandler?.handle(
                input: .selectedGroupUpdated(group)
            )
        case .recordUpdated:
            challengeInputHandler?.handle(input: .recordUpdated)
        case let .reportConfirmationRequested(recordId):
            mainContainerViewController?.showAlert(
                configuration: MainAlertConfiguration(
                    title: "게시물을 신고하시겠어요?",
                    contents: "신고한 게시물은 검토 후 삭제 처리할 예정입니다.",
                    leadingButton: MAlertButton("취소", style: .gray),
                    trailingButton: MAlertButton("신고하기") { [weak self] in
                        guard let self else { return }
                        self.mainContainerViewController?.setLoading(true)
                        self.feedInputHandler?.handle(
                            input: .reportConfirmed(recordId: recordId)
                        )
                    },
                    dismissOnBackgroundTap: false
                )
            )
        case .reportSucceeded:
            mainContainerViewController?.showAlert(
                configuration: MainAlertConfiguration(
                    title: "신고가 완료되었어요",
                    contents: "검토 및 처리는 최대 7일까지 걸릴 수 있어요."
                )
            )
        case let .reportFailed(error):
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
