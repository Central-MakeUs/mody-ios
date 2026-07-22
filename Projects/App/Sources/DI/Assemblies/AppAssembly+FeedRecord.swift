//
//  AppAssembly+FeedRecord.swift
//  Mody
//
//  Created by 김동준 on 7/12/26
//

import Swinject
import FeedInterface
import Feed

extension AppAssembly {
    func assembleFeedRecordReactor(in container: Container) {
        container.register(((FeedRecordRouter, FeedRecordType, FeedRecordOutputHandler) -> FeedRecordReactor).self) { resolver in
            return { router, recordType, outputHandler in
                let feedUseCase: FeedUseCase = resolver.resolve()

                return FeedRecordReactor(
                    router: router,
                    recordType: recordType,
                    feedUseCase: feedUseCase,
                    outputHandler: outputHandler
                )
            }
        }
    }
}
