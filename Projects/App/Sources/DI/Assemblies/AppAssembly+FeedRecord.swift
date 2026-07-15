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
        container.register(((FeedRecordRouter, FeedRecordType) -> FeedRecordReactor).self) { _ in
            return { router, recordType in
                return FeedRecordReactor(
                    router: router,
                    recordType: recordType
                )
            }
        }
    }
}
