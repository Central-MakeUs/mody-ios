//
//  FeedInterface.swift
//  FeedInterface
//
//  Created by 김동준 on 6/30/26
//

import UIKit

public protocol FeedBuildable {
    @MainActor
    func makeFeedViewController(router: FeedRouter) -> UIViewController
}
