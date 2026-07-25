//
//  FeedDemoDependencyContainer.swift
//  FeedDemo
//
//  Created by 김동준 on 7/22/26.
//

import CoreAuthInterface
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
        self.cameraCaptureBuilder = CameraCaptureBuilder(
            temporaryImageFileUseCase: temporaryImageFileUseCase
        )
    }

    func makeFeedBuildable() -> FeedBuildable {
        let feedUseCase = FeedUseCase(feedRepository: feedRepository)

        return FeedBuilder(
            makeFeedReactor: { [authUseCase, groupUseCase] router in
                FeedReactor(
                    authUseCase: authUseCase,
                    groupUseCase: groupUseCase,
                    feedUseCase: feedUseCase,
                    router: router
                )
            },
            makeFeedRecordReactor: {
                [imageUploadUseCase, temporaryImageFileUseCase]
                router,
                recordType,
                outputHandler in
                FeedRecordReactor(
                    router: router,
                    recordType: recordType,
                    feedUseCase: feedUseCase,
                    imageUploadUseCase: imageUploadUseCase,
                    temporaryImageFileUseCase: temporaryImageFileUseCase,
                    outputHandler: outputHandler
                )
            },
            cameraCaptureBuilder: cameraCaptureBuilder,
            imageLoader: NukeRemoteImageLoader.shared
        )
    }
}
