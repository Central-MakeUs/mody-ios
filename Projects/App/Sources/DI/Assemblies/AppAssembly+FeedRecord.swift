//
//  AppAssembly+FeedRecord.swift
//  Mody
//
//  Created by 김동준 on 7/12/26
//

import Swinject
import CoreAnalyticsInterface
import CoreModyImageInterface
import FeedInterface
import Feed

extension AppAssembly {
    func assembleFeedRecordReactor(in container: Container) {
        container.register(((FeedRecordRouter, FeedRecordType, FeedRecordOutputHandler) -> FeedRecordReactor).self) { resolver in
            return { router, recordType, outputHandler in
                let feedUseCase: FeedUseCase = resolver.resolve()
                let imageUploadUseCase: ImageUploadUseCaseProtocol = resolver.resolve()
                let temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol = resolver.resolve()
                let analyticsUseCase: AnalyticsUseCaseProtocol = resolver.resolve()

                return FeedRecordReactor(
                    router: router,
                    recordType: recordType,
                    feedUseCase: feedUseCase,
                    imageUploadUseCase: imageUploadUseCase,
                    temporaryImageFileUseCase: temporaryImageFileUseCase,
                    analyticsUseCase: analyticsUseCase,
                    output: { [weak outputHandler] output in
                        outputHandler?.handle(output: output)
                    }
                )
            }
        }
    }
}
