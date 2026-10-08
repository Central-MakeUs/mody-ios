//
//  FeedDemoDependencyContainer.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import CoreAuthTesting
import CoreCamera
import CoreCameraInterface
import CoreModyImage
import CoreModyImageInterface
import Feed
import FeedInterface
import ModyGroupInterface

@MainActor
final class FeedDemoDependencyContainer {
    private var repository: FeedDemoRepositoryStub?

    func makeBuilder(for scenario: FeedDemoScenario) -> FeedBuildable {
        let repository = FeedDemoRepositoryStub(scenario: scenario)
        self.repository = repository
        let feedUseCase = FeedUseCase(
            feedRepository: repository
        )
        let authUseCase = AuthUseCaseStub(
            signInResult: .failure(CancellationError()),
            userInfoResult: .success(UserInfoFixture.make(
                memberId: 100, nickname: "내 기록", profileImageUrl: "", daysTogether: 1
            )),
            logoutResult: .success(()),
            deleteAccountResult: .success(()),
            responseDelay: .milliseconds(500)
        )
        let groupUseCase: GroupUseCaseProtocol = FeedDemoGroupUseCaseStub(scenario: scenario)
        let imageUploadUseCase: ImageUploadUseCaseProtocol = FeedDemoImageUploadUseCaseStub(scenario: scenario)
        let temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol = TemporaryImageFileUseCase(
            repository: TemporaryImageFileRepository()
        )

        return FeedBuilder(
            makeFeedReactor: { router, outputHandler in
                FeedReactor(
                    authUseCase: authUseCase,
                    groupUseCase: groupUseCase,
                    feedUseCase: feedUseCase,
                    router: router,
                    output: { [weak outputHandler] output in
                        outputHandler?.handle(output: output)
                    }
                )
            },
            makeFeedRecordReactor: { router, recordType, outputHandler in
                FeedRecordReactor(
                    router: router,
                    recordType: recordType,
                    feedUseCase: feedUseCase,
                    imageUploadUseCase: imageUploadUseCase,
                    temporaryImageFileUseCase: temporaryImageFileUseCase,
                    output: { [weak outputHandler] output in
                        outputHandler?.handle(output: output)
                    }
                )
            },
            cameraCaptureBuilder: CameraCaptureBuilder(
                temporaryImageFileUseCase: temporaryImageFileUseCase
            ),
            imageLoader: FeedDemoImageLoaderStub()
        )
    }

    func addDemoRecord() async {
        await repository?.addDemoRecord()
    }
}
