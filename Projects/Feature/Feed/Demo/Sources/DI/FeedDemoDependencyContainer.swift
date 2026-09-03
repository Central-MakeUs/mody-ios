//
//  FeedDemoDependencyContainer.swift
//  FeedDemo
//
//  Created by 김동준 on 7/22/26.
//

import CoreAuthInterface
import CoreAnalyticsInterface
import CoreCamera
import CoreCameraInterface
import CoreModyImageInterface
import Feed
import FeedInterface
import CoreModyImage
import ModyGroupInterface

final class FeedDemoDependencyContainer {
    private let feedRepository: FeedRepositoryProtocol
    private let authUseCase: AuthUseCaseProtocol
    private let groupUseCase: GroupUseCaseProtocol
    private let cameraCaptureBuilder: CameraCaptureBuildable
    private let imageUploadUseCase: ImageUploadUseCaseProtocol
    private let temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol
    private let analyticsUseCase: AnalyticsUseCaseProtocol

    init(
        feedRepository: FeedRepositoryProtocol = FeedDemoMockRepository(),
        authUseCase: AuthUseCaseProtocol = FeedDemoAuthUseCase(),
        groupUseCase: GroupUseCaseProtocol = FeedDemoGroupUseCase(),
        imageUploadUseCase: ImageUploadUseCaseProtocol = FeedDemoImageUploadUseCase(),
        temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol = TemporaryImageFileUseCase(
            repository: TemporaryImageFileRepository()
        )
    ) {
        self.feedRepository = feedRepository
        self.authUseCase = authUseCase
        self.groupUseCase = groupUseCase
        self.imageUploadUseCase = imageUploadUseCase
        self.temporaryImageFileUseCase = temporaryImageFileUseCase
        self.analyticsUseCase = FeedDemoAnalyticsUseCase()
        self.cameraCaptureBuilder = CameraCaptureBuilder(
            temporaryImageFileUseCase: temporaryImageFileUseCase
        )
    }

    func makeFeedBuildable() -> FeedBuildable {
        let feedUseCase = FeedUseCase(feedRepository: feedRepository)

        return FeedBuilder(
            makeFeedReactor: { router, outputHandler in
                FeedReactor(
                    authUseCase: self.authUseCase,
                    groupUseCase: self.groupUseCase,
                    feedUseCase: feedUseCase,
                    analyticsUseCase: self.analyticsUseCase,
                    router: router,
                    output: { [weak outputHandler] output in
                        outputHandler?.handle(output: output)
                    }
                )
            },
            makeFeedRecordReactor: {
                router,
                recordType,
                outputHandler in
                FeedRecordReactor(
                    router: router,
                    recordType: recordType,
                    feedUseCase: feedUseCase,
                    imageUploadUseCase: self.imageUploadUseCase,
                    temporaryImageFileUseCase: self.temporaryImageFileUseCase,
                    analyticsUseCase: self.analyticsUseCase,
                    output: { [weak outputHandler] output in
                        outputHandler?.handle(output: output)
                    }
                )
            },
            cameraCaptureBuilder: cameraCaptureBuilder,
            imageLoader: NukeRemoteImageLoader.shared
        )
    }
}

private struct FeedDemoAnalyticsUseCase: AnalyticsUseCaseProtocol {
    func setUserID(_ userID: String) {}
    func setUserNickname(_ nickname: String) {}
    func reset() {}
    func log(_ event: AmplitudeLogEvent) {}
    func viewDidLoad(screenName: String) {}
}
