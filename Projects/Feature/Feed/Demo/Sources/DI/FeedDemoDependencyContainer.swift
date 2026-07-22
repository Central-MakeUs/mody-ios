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
import FeedTesting
import ModyGroupInterface

final class FeedDemoDependencyContainer {
    private let feedRepository: FeedRepositoryProtocol
    private let authUseCase: AuthUseCaseProtocol
    private let groupUseCase: GroupUseCaseProtocol
    private let cameraCaptureBuilder: CameraCaptureBuildable

    init(
        feedRepository: FeedRepositoryProtocol = FeedMockRepository(),
        authUseCase: AuthUseCaseProtocol = FeedDemoAuthUseCase(),
        groupUseCase: GroupUseCaseProtocol = FeedDemoGroupUseCase(),
        cameraCaptureBuilder: CameraCaptureBuildable = CameraCaptureBuilder()
    ) {
        self.feedRepository = feedRepository
        self.authUseCase = authUseCase
        self.groupUseCase = groupUseCase
        self.cameraCaptureBuilder = cameraCaptureBuilder
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
            makeFeedRecordReactor: { router, recordType, outputHandler in
                FeedRecordReactor(
                    router: router,
                    recordType: recordType,
                    feedUseCase: feedUseCase,
                    outputHandler: outputHandler
                )
            },
            cameraCaptureBuilder: cameraCaptureBuilder
        )
    }
}
