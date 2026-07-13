//
//  FeedRoute.swift
//  FeedInterface
//
//  Created by 김동준 on 6/30/26
//

public enum FeedRoute: Equatable {
    case groupMenu
}

@MainActor
public protocol FeedRouter: AnyObject {
    func route(from route: FeedRoute)
}
