//
//  FeedBuilder.swift
//  Feed
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import FeedInterface

public struct FeedBuilder: FeedBuildable {
    private let makeFeedReactor: () -> FeedReactor
    
    public init(
        makeFeedReactor: @escaping () -> FeedReactor
    ) {
        self.makeFeedReactor = makeFeedReactor
    }

    @MainActor
    public func makeFeedViewController(router: FeedRouter) -> UIViewController {
        return FeedViewController(
            router: router,
            reactor: makeFeedReactor()
        )
    }
}
