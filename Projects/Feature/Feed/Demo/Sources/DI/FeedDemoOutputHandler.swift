//
//  FeedDemoOutputHandler.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import DesignSystem
import FeedInterface
import SwiftUI
import UIKit

@MainActor
final class FeedDemoOutputHandler: FeedOutputHandler, FeedRecordOutputHandler {
    private weak var router: FeedDemoRouter?
    private let onOutput: (String) -> Void
    private weak var navigationController: UINavigationController?
    private var overlayViewController: UIViewController?

    init(onOutput: @escaping (String) -> Void) {
        self.onOutput = onOutput
    }

    func attach(router: FeedDemoRouter, navigationController: UINavigationController) {
        dismissOverlay()
        self.router = router
        self.navigationController = navigationController
    }

    func handle(output: FeedOutput) {
        switch output {
        case let .selectedGroupUpdated(group):
            onOutput("그룹 선택: \(group?.name ?? "없음")")
        case .recordUpdated:
            onOutput("기록 생성 후 피드 갱신")
        case let .reportConfirmationRequested(recordId):
            onOutput("신고 확인 요청")
            presentConfirmation(
                title: "게시물을 신고하시겠어요?",
                message: "신고한 게시물은 검토 후 삭제 처리할 예정입니다.",
                confirmTitle: "신고하기"
            ) { [weak self] in
                self?.router?.sendFeedInput(.reportConfirmed(recordId: recordId))
            }
        case .reportSucceeded:
            onOutput("신고 성공")
            presentAlert(title: "신고가 완료되었어요", message: "검토 및 처리는 최대 7일까지 걸릴 수 있어요.")
        case let .reportFailed(error):
            onOutput("신고 실패")
            presentError(error)
        case let .deleteConfirmationRequested(recordId):
            onOutput("삭제 확인 요청")
            presentConfirmation(
                title: "게시물을 삭제하시겠어요?",
                message: "한 번 삭제한 게시물은 복구할 수 없어요.",
                confirmTitle: "삭제"
            ) { [weak self] in
                self?.router?.sendFeedInput(.deleteConfirmed(recordId: recordId))
            }
        case .deleteSucceeded:
            onOutput("삭제 성공 · 피드 갱신")
            dismissOverlay()
        case let .deleteFailed(error):
            onOutput("삭제 실패")
            presentError(error)
        }
    }

    func handle(output: FeedRecordOutput) {
        switch output {
        case .recordCreated:
            onOutput("기록 생성 성공 · 피드 복귀")
            router?.recordCreated()
        }
    }

    func presentAlert(title: String, message: String) {
        showOverlay(MAlertView(
            title: title,
            contents: message,
            trailingButton: MAlertButton("확인") { [weak self] in
                self?.dismissOverlay()
            },
            onDismiss: { [weak self] in self?.dismissOverlay() }
        ))
    }
}

private extension FeedDemoOutputHandler {
    func presentConfirmation(
        title: String,
        message: String,
        confirmTitle: String,
        onConfirm: @escaping () -> Void
    ) {
        showOverlay(MAlertView(
            title: title,
            contents: message,
            leadingButton: MAlertButton("취소", style: .gray) { [weak self] in
                self?.dismissOverlay()
            },
            trailingButton: MAlertButton(confirmTitle) { [weak self] in
                guard let self else { return }
                self.showOverlay(
                    MLoadingIndicatorView()
                        .greedyFrame()
                        .background(Color.systemBlack.opacity(0.6).ignoresSafeArea())
                )
                onConfirm()
            },
            dismissOnBackgroundTap: false
        ))
    }

    func presentError(_ error: NetworkError) {
        if case let .serverError(_, _, fallback) = error {
            presentAlert(title: fallback.title, message: fallback.message)
        } else {
            presentAlert(title: error.title, message: error.message)
        }
    }

    func showOverlay<Content: View>(_ content: Content) {
        guard let parent = navigationController?.topViewController else { return }
        let previousOverlay = overlayViewController
        let hostingController = UIHostingController(rootView: content)
        hostingController.safeAreaRegions = []
        parent.addChild(hostingController)
        hostingController.view.backgroundColor = .clear
        hostingController.view.frame = parent.view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parent.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: parent)
        overlayViewController = hostingController
        removeOverlay(previousOverlay)
    }

    func dismissOverlay() {
        removeOverlay(overlayViewController)
        overlayViewController = nil
    }

    func removeOverlay(_ viewController: UIViewController?) {
        viewController?.willMove(toParent: nil)
        viewController?.view.removeFromSuperview()
        viewController?.removeFromParent()
    }
}
