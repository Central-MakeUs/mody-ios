//
//  MyPageDemoDependencyContainer.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import CoreAuthTesting
import CoreCameraTesting
import CoreHealthTesting
import CoreNetworkTesting
import CoreNotificationTesting
import UIKit
import CoreModyImage
import CoreModyImageTesting
import MyPage
import MyPageInterface

@MainActor
final class MyPageDemoDependencyContainer {
    func makeBuilder(for scenario: MyPageScenario) -> MyPageBuildable {
        let profileData = MyPageDemoProfileData()
        let network = CoreNetworkStub { endpoint in
            try await profileData.response(to: endpoint, scenario: scenario)
        }
        let auth = AuthUseCaseStub(
            signIn: { _, _ in throw CancellationError() },
            getUserInfo: { _ in
                if scenario == .userLookupFailure { throw NetworkError.networkUnavailable }
                return UserInfoFixture.make(nickname: await profileData.name, daysTogether: 20)
            },
            logout: {
                if scenario == .logoutFailure { throw NetworkError.networkUnavailable }
            },
            deleteAccount: {
                if scenario == .deleteFailure { throw NetworkError.networkUnavailable }
            }
        )
        let myPageUseCase = MyPageUseCase(
            myPageRepository: MyPageRepository(network: network)
        )
        let notificationUseCase = MyPageNotificationSettingUseCase(
            repository: MyPageDemoNotificationRepository(repository: MyPageNotificationSettingRepository(network: network))
        )

        let cameraCaptureBuilder: CameraCaptureBuilderStub
        if scenario == .photoCaptureCancel {
            cameraCaptureBuilder = CameraCaptureBuilderStub(captureResult: nil)
        } else {
            cameraCaptureBuilder = CameraCaptureBuilderStub {
                CameraCaptureResultFixture.make(
                    previewImage: UIImage(systemName: "person.crop.circle") ?? UIImage(),
                    fileName: "mypage-demo-profile.jpg"
                )
            }
        }

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
                    imageUploadUseCase: ImageUploadUseCaseStub(
                        result: scenario == .photoUploadFailure
                            ? .failure(NetworkError.networkUnavailable) : .success("demo-profile-image")
                    ),
                    temporaryImageFileUseCase: TemporaryImageFileUseCaseStub.metadataOnly(),
                    router: { router.route(from: $0) },
                    output: { output.handle(output: $0) }
                )
            },
            makeNotificationSettingsFeature: { router in
                NotificationSettingsFeature(
                    notificationPermission: NotificationPermissionStub(
                        isNotDetermined: scenario == .notificationPermissionRequest,
                        isGranted: scenario != .notificationPermissionDenied,
                        requestResult: true
                    ),
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
                    healthPermissionInterface: HealthPermissionStub(
                        shouldShowPrompt: scenario == .healthPermissionPrompt,
                        requestResult: true
                    ),
                    router: { router.route(from: $0) }
                )
            },
            imageLoader: NukeRemoteImageLoader.shared,
            cameraCaptureBuilder: cameraCaptureBuilder
        )
    }
}
