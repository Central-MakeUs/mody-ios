//
//  MyPageDemoRouter.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import MyPageInterface
import UIKit

@MainActor
final class MyPageDemoRouter: MyPageRouter, MyPageProfileRouter,
    MyPageNotificationSettingsRouter, MyPageGroupSettingsRouter,
    MyPageHealthDataSettingsRouter, MyPageOutputHandler {
    private let onRoute: (String) -> Void
    private let onOutput: (MyPageOutput) -> Void
    private var builder: MyPageBuildable?
    private weak var navigationController: UINavigationController?
    private weak var homeInput: MyPageInputHandler?

    init(onRoute: @escaping (String) -> Void, onOutput: @escaping (MyPageOutput) -> Void) {
        self.onRoute = onRoute
        self.onOutput = onOutput
    }

    func attach(builder: MyPageBuildable, navigationController: UINavigationController) {
        self.builder = builder
        self.navigationController = navigationController
    }

    func setHomeInput(_ input: MyPageInputHandler) {
        homeInput = input
    }

    func route(from route: MyPageRoute) {
        guard let builder else { return }

        let controller: UIViewController
        switch route {
        case let .routeToProfile(imageURL, avatar):
            onRoute("프로필")
            controller = builder.makeProfileViewController(
                profileImageURL: imageURL,
                defaultAvatar: avatar,
                router: self,
                outputHandler: self
            )
        case .routeToNotificationSettings:
            onRoute("알림 설정")
            controller = builder.makeNotificationSettingsViewController(router: self)
        case .routeToGroupSettings:
            onRoute("그룹 설정")
            controller = builder.makeGroupSettingsViewController(router: self, outputHandler: self)
        case .routeToHealthDataSettings:
            onRoute("건강 데이터 연동 설정")
            controller = builder.makeHealthDataSettingsViewController(router: self)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    func route(from route: MyPageProfileRoute) {
        switch route {
        case .back:
            onRoute("프로필 → 마이페이지")
            navigationController?.popViewController(animated: true)
        case .routeToSignIn:
            onRoute("로그인")
            navigationController?.popToRootViewController(animated: true)
        }
    }

    func route(from route: MyPageNotificationSettingsRoute) {
        onRoute("알림 설정 → 마이페이지")
        navigationController?.popViewController(animated: true)
    }

    func route(from route: MyPageGroupSettingsRoute) {
        switch route {
        case .back:
            onRoute("그룹 설정 → 마이페이지")
            navigationController?.popViewController(animated: true)
        case .routeToGroupParticipate:
            onRoute("그룹 참여")
            navigationController?.popToRootViewController(animated: true)
        }
    }

    func route(from route: MyPageHealthDataSettingsRoute) {
        onRoute("건강 데이터 연동 설정 → 마이페이지")
        navigationController?.popViewController(animated: true)
    }

    func handle(output: MyPageOutput) {
        onOutput(output)
        switch output {
        case .profileUpdated:
            homeInput?.handle(input: .profileUpdated)
        case .weightRecordStarted, .weightRecordSucceeded, .weightRecordFailed, .groupUpdated:
            break
        }
    }
}
