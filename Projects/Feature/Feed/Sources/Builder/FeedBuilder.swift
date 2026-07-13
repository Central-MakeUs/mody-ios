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
    
    public init(
        makeFeedReactor: @escaping (FeedRouter) -> FeedReactor
    ) {
        self.makeFeedReactor = makeFeedReactor
    }

    @MainActor
    public func makeFeedViewController(router: FeedRouter) -> UIViewController {
        return FeedViewController(reactor: makeFeedReactor(router))
    }
}
