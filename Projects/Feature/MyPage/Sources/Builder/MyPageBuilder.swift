//
//  MyPageBuilder.swift
//  MyPage
//
//  Created by 김동준 on 6/30/26
//

import CoreCameraInterface
import CoreModyImageInterface
import UIKit
import SwiftUI
import CommonDomain
import MyPageInterface
import ComposableArchitecture

public struct MyPageBuilder: MyPageBuildable {
    private let makeMyPageFeature: (MyPageRouter, MyPageOutputHandler) -> MyPageFeature
    private let makeProfileFeature: (MyPageProfileRouter, MyPageOutputHandler) -> ProfileFeature
    private let makeNotificationSettingsFeature: (MyPageNotificationSettingsRouter) -> NotificationSettingsFeature
    private let makeGroupSettingsFeature: (MyPageGroupSettingsRouter, MyPageOutputHandler) -> GroupSettingsFeature
    private let makeHealthDataSettingsFeature: (MyPageHealthDataSettingsRouter) -> HealthDataSettingsFeature
    private let imageLoader: RemoteImageLoading
    private let cameraCaptureBuilder: CameraCaptureBuildable
    
    public init(
        makeMyPageFeature: @escaping (MyPageRouter, MyPageOutputHandler) -> MyPageFeature,
        makeProfileFeature: @escaping (MyPageProfileRouter, MyPageOutputHandler) -> ProfileFeature,
        makeNotificationSettingsFeature: @escaping (MyPageNotificationSettingsRouter) -> NotificationSettingsFeature,
        makeGroupSettingsFeature: @escaping (MyPageGroupSettingsRouter, MyPageOutputHandler) -> GroupSettingsFeature,
        makeHealthDataSettingsFeature: @escaping (MyPageHealthDataSettingsRouter) -> HealthDataSettingsFeature,
        imageLoader: RemoteImageLoading,
        cameraCaptureBuilder: CameraCaptureBuildable
    ) {
        self.makeMyPageFeature = makeMyPageFeature
        self.makeProfileFeature = makeProfileFeature
        self.makeNotificationSettingsFeature = makeNotificationSettingsFeature
        self.makeGroupSettingsFeature = makeGroupSettingsFeature
        self.makeHealthDataSettingsFeature = makeHealthDataSettingsFeature
        self.imageLoader = imageLoader
        self.cameraCaptureBuilder = cameraCaptureBuilder
    }

    @MainActor
    public func makeMyPageViewController(
        router: MyPageRouter,
        outputHandler: MyPageOutputHandler
    ) -> UIViewController & MyPageInputHandler {
        let store: StoreOf<MyPageFeature> = .init(initialState: MyPageFeature.State()) {
            makeMyPageFeature(router, outputHandler)
        }

        return MyPageHostingController(
            store: store,
            imageLoader: imageLoader
        )
    }

    @MainActor
    public func makeProfileViewController(
        profileImageURL: URL?,
        defaultAvatar: DefaultAvatar,
        router: MyPageProfileRouter,
        outputHandler: MyPageOutputHandler
    ) -> UIViewController {
        let store: StoreOf<ProfileFeature> = .init(
            initialState: ProfileFeature.State(
                profileImageURL: profileImageURL,
                defaultAvatar: defaultAvatar
            )
        ) {
            makeProfileFeature(router, outputHandler)
        }
        let view = ProfileView(
            store: store,
            imageLoader: imageLoader,
            cameraCaptureBuilder: cameraCaptureBuilder
        )

        return UIHostingController(rootView: view)
    }

    @MainActor
    public func makeNotificationSettingsViewController(
        router: MyPageNotificationSettingsRouter
    ) -> UIViewController {
        let store: StoreOf<NotificationSettingsFeature> = .init(
            initialState: NotificationSettingsFeature.State()
        ) {
            makeNotificationSettingsFeature(router)
        }
        let view = NotificationSettingsView(store: store)

        return UIHostingController(rootView: view)
    }

    @MainActor
    public func makeGroupSettingsViewController(
        router: MyPageGroupSettingsRouter,
        outputHandler: MyPageOutputHandler
    ) -> UIViewController {
        let store: StoreOf<GroupSettingsFeature> = .init(
            initialState: GroupSettingsFeature.State()
        ) {
            makeGroupSettingsFeature(router, outputHandler)
        }
        let view = GroupSettingsView(store: store)

        return UIHostingController(rootView: view)
    }

    @MainActor
    public func makeHealthDataSettingsViewController(
        router: MyPageHealthDataSettingsRouter
    ) -> UIViewController {
        let store: StoreOf<HealthDataSettingsFeature> = .init(
            initialState: HealthDataSettingsFeature.State()
        ) {
            makeHealthDataSettingsFeature(router)
        }
        let view = HealthDataSettingsView(store: store)

        return UIHostingController(rootView: view)
    }
}
