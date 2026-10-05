//
//  FeedDemoDependencyContainer.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

import CoreAuthInterface
import CoreCamera
import CoreCameraInterface
import CoreModyImage
import CoreModyImageInterface
import Feed
import FeedInterface
import ModyGroupInterface

@MainActor
final class FeedDemoDependencyContainer {
    func makeBuilder(for scenario: FeedDemoScenario) -> FeedBuildable {
        let feedUseCase = FeedUseCase(
            feedRepository: FeedDemoRepositoryStub(scenario: scenario)
        )
        let authUseCase: AuthUseCaseProtocol = FeedDemoAuthUseCaseStub()
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
}
