//
//  MyPageDemoDependencyContainer.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import CoreModyImage
import MyPage
import MyPageInterface

@MainActor
final class MyPageDemoDependencyContainer {
    func makeBuilder(for scenario: MyPageScenario) -> MyPageBuildable {
        let profileData = MyPageDemoProfileData()
        let auth = MyPageDemoAuthStub(scenario: scenario, profileData: profileData)
        let myPageUseCase = MyPageUseCase(
            myPageRepository: MyPageDemoRepositoryStub(
                scenario: scenario,
                profileData: profileData
            )
        )
        let notificationUseCase = MyPageNotificationSettingUseCase(
            repository: MyPageDemoNotificationRepositoryStub(scenario: scenario)
        )

        return MyPageBuilder(
            makeMyPageFeature: { router, output in
                MyPageFeature(
                    authUseCase: auth,
                    myPageUseCase: myPageUseCase,
                    router: { router.route(from: $0) },
                    output: { output.handle(output: $0) }
                )
            },
            makeProfileFeature: { router, output in
                ProfileFeature(
                    authUseCase: auth,
                    myPageUseCase: myPageUseCase,
                    imageUploadUseCase: MyPageDemoImageStub(scenario: scenario),
                    temporaryImageFileUseCase: MyPageDemoImageStub(),
                    router: { router.route(from: $0) },
                    output: { output.handle(output: $0) }
                )
            },
            makeNotificationSettingsFeature: { router in
                NotificationSettingsFeature(
                    notificationPermission: MyPageDemoNotificationPermissionStub(scenario: scenario),
                    notificationSettingUseCase: notificationUseCase,
                    router: { router.route(from: $0) }
                )
            },
            makeGroupSettingsFeature: { router, output in
                GroupSettingsFeature(
                    groupUseCase: MyPageDemoGroupStub(scenario: scenario),
                    router: { router.route(from: $0) },
                    output: { output.handle(output: $0) }
                )
            },
            makeHealthDataSettingsFeature: { router in
                HealthDataSettingsFeature(
                    healthPermissionInterface: MyPageDemoHealthPermissionStub(
                        shouldRequest: scenario == .healthPermissionPrompt
                    ),
                    router: { router.route(from: $0) }
                )
            },
            imageLoader: NukeRemoteImageLoader.shared,
            cameraCaptureBuilder: MyPageDemoCameraStub(scenario: scenario)
        )
    }
}
