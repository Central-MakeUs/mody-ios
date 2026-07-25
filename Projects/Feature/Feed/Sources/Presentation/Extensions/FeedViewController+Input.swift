//
//  FeedViewController+Input.swift
//  Feed
//
//  Created by 김동준 on 7/24/26.
//

import FeedInterface

extension FeedViewController: FeedInputHandler {
    public func handle(input: FeedInput) {
        reactor?.action.onNext(.input(input))
    }
}
