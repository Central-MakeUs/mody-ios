//
//  FeedDemoDependencyContainer.swift
//  FeedDemo
//
//  Created by 김동준 on 7/22/26.
//

import CoreAuthInterface
import CoreCamera
import CoreCameraInterface
import Feed
import FeedInterface
import ModyGroupInterface

final class FeedDemoDependencyContainer {
    private let feedRepository: FeedRepositoryProtocol
    private let authUseCase: AuthUseCaseProtocol
    private let groupUseCase: GroupUseCaseProtocol
    private let cameraCaptureBuilder: CameraCaptureBuildable
    private let imageUploadUseCase: ImageUploadUseCaseProtocol

    init(
        feedRepository: FeedRepositoryProtocol = FeedDemoMockRepository(),
        authUseCase: AuthUseCaseProtocol = FeedDemoAuthUseCase(),
        groupUseCase: GroupUseCaseProtocol = FeedDemoGroupUseCase(),
        cameraCaptureBuilder: CameraCaptureBuildable = CameraCaptureBuilder(),
        imageUploadUseCase: ImageUploadUseCaseProtocol = FeedDemoImageUploadUseCase()
    ) {
        self.feedRepository = feedRepository
        self.authUseCase = authUseCase
        self.groupUseCase = groupUseCase
        self.cameraCaptureBuilder = cameraCaptureBuilder
        self.imageUploadUseCase = imageUploadUseCase
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
            makeFeedRecordReactor: { [imageUploadUseCase] router, recordType, outputHandler in
                FeedRecordReactor(
                    router: router,
                    recordType: recordType,
                    feedUseCase: feedUseCase,
                    imageUploadUseCase: imageUploadUseCase,
                    outputHandler: outputHandler
                )
            },
            cameraCaptureBuilder: cameraCaptureBuilder
        )
    }
}
