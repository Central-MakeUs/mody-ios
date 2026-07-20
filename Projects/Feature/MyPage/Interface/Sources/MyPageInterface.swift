//
//  MyPageInterface.swift
//  MyPageInterface
//
//  Created by 김동준 on 6/30/26
//

import CommonDomain
import UIKit

public protocol MyPageBuildable {
    @MainActor
    func makeMyPageViewController(
        router: MyPageRouter,
        outputHandler: MyPageOutputHandler
    ) -> UIViewController & MyPageInputHandler

    @MainActor
    func makeProfileViewController(
        profileImageURL: URL?,
        defaultAvatar: DefaultAvatar,
        router: MyPageProfileRouter,
        outputHandler: MyPageOutputHandler
    ) -> UIViewController

    @MainActor
    func makeNotificationSettingsViewController(
        router: MyPageNotificationSettingsRouter
    ) -> UIViewController

    @MainActor
    func makeGroupSettingsViewController(
        router: MyPageGroupSettingsRouter
    ) -> UIViewController

    @MainActor
    func makeHealthDataSettingsViewController(
        router: MyPageHealthDataSettingsRouter
    ) -> UIViewController
}
