//
//  FeedBuilder.swift
//  Feed
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import FeedInterface

public struct FeedBuilder: FeedBuildable {
    private let makeFeedReactor: (FeedRouter) -> FeedReactor
    private let makeFeedRecordReactor: (FeedRecordRouter, FeedRecordType) -> FeedRecordReactor
    
    public init(
        makeFeedReactor: @escaping (FeedRouter) -> FeedReactor,
        makeFeedRecordReactor: @escaping (FeedRecordRouter, FeedRecordType) -> FeedRecordReactor
    ) {
        self.makeFeedReactor = makeFeedReactor
        self.makeFeedRecordReactor = makeFeedRecordReactor
    }

    @MainActor
    public func makeFeedViewController(router: FeedRouter) -> UIViewController {
        return FeedViewController(reactor: makeFeedReactor(router))
    }

    @MainActor
    public func makeFeedRecordViewController(
        router: FeedRecordRouter,
        recordType: FeedRecordType
    ) -> UIViewController {
        return FeedRecordViewController(reactor: makeFeedRecordReactor(router, recordType))
    }
}
