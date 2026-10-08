//
//  ChallengeDemoRouter.swift
//  ChallengeDemo
//
//  Created by 김동준 on 10/5/26.
//

import ChallengeInterface
import CommonDomain
import DesignSystem
import SwiftUI
import UIKit

@MainActor
final class ChallengeDemoRouter: ChallengeRouter, ChallengeChangeRouter,
    ChallengeWeeklyDetailRouter, ChallengeOutputHandler {
    private let onRoute: (String) -> Void
    private let onOutput: (String) -> Void
    private var builder: ChallengeBuildable?
    private weak var navigationController: UINavigationController?
    private weak var homeInput: ChallengeInputHandler?
    private var overlayViewController: UIViewController?

    init(onRoute: @escaping (String) -> Void, onOutput: @escaping (String) -> Void) {
        self.onRoute = onRoute
        self.onOutput = onOutput
    }

    func attach(builder: ChallengeBuildable, navigationController: UINavigationController) {
        dismissOverlay()
        self.builder = builder
        self.navigationController = navigationController
    }

    func setHomeInput(_ input: ChallengeInputHandler) {
        homeInput = input
    }

    func route(from route: ChallengeRoute) {
        guard let builder else { return }
        switch route {
        case let .routeToChallengeChange(groupId):
            onRoute("챌린지 변경")
            navigationController?.pushViewController(
                builder.makeChallengeChangeViewController(
                    groupId: groupId, router: self, outputHandler: self
                ),
                animated: true
            )
        case let .routeToWeeklyDetail(groupId, challengeId, groupChallengeId):
            onRoute("주간 챌린지 상세")
            navigationController?.pushViewController(
                builder.makeChallengeWeeklyDetailViewController(
                    groupId: groupId, challengeId: challengeId,
                    groupChallengeId: groupChallengeId, router: self, outputHandler: self
                ),
                animated: true
            )
        }
    }

    func route(from route: ChallengeChangeRoute) {
        onRoute("챌린지 변경 → 챌린지 홈")
        navigationController?.popViewController(animated: true)
    }

    func route(from route: ChallengeWeeklyDetailRoute) {
        onRoute("주간 챌린지 상세 → 챌린지 홈")
        navigationController?.popViewController(animated: true)
    }

    func handle(output: ChallengeOutput) {
        switch output {
        case .nudgeStarted:
            onOutput("콕 찌르기 시작")
            showOverlay(
                MLoadingIndicatorView()
                    .greedyFrame()
                    .background(Color.systemBlack.opacity(0.6).ignoresSafeArea())
            )
        case let .nudgeSucceeded(nickname):
            onOutput("\(nickname) 콕 찌르기 성공")
            presentAlert(title: "콕 찌르기 완료", message: "\(nickname) 님을 콕 찔렀습니다!")
        case let .showAlert(error):
            onOutput("오류 · \(error.title): \(error.message)")
            let presentedError: NetworkError
            if case let .serverError(_, _, fallback) = error {
                presentedError = fallback
            } else {
                presentedError = error
            }
            presentAlert(title: presentedError.title, message: presentedError.message)
        case .stepChallengeChanged:
            onOutput("챌린지 변경 완료")
            homeInput?.handle(input: .stepChallengeChanged)
        case .weeklyChallengeProofCreated:
            onOutput("주간 인증 생성 완료")
            homeInput?.handle(input: .weeklyChallengeProofCreated)
        case let .shareWeeklyChallengeImageURL(url):
            onOutput("공유 이미지 URL · \(url)")
        }
    }

    private func presentAlert(title: String, message: String) {
        showOverlay(MAlertView(
            title: title,
            contents: message,
            trailingButton: MAlertButton("확인") { [weak self] in
                self?.dismissOverlay()
            },
            onDismiss: { [weak self] in self?.dismissOverlay() }
        ))
    }

    private func showOverlay<Content: View>(_ content: Content) {
        guard let parent = navigationController?.topViewController else { return }
        let previous = overlayViewController
        let controller = UIHostingController(rootView: content)
        controller.safeAreaRegions = []
        parent.addChild(controller)
        controller.view.backgroundColor = .clear
        controller.view.frame = parent.view.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parent.view.addSubview(controller.view)
        controller.didMove(toParent: parent)
        overlayViewController = controller
        removeOverlay(previous)
    }

    private func dismissOverlay() {
        removeOverlay(overlayViewController)
        overlayViewController = nil
    }

    private func removeOverlay(_ controller: UIViewController?) {
        controller?.willMove(toParent: nil)
        controller?.view.removeFromSuperview()
        controller?.removeFromParent()
    }
}
