//
//  FeedRecordRoute.swift
//  FeedInterface
//
//  Created by 김동준 on 7/12/26.
//

public enum FeedRecordRoute: Equatable {
    case back
}

@MainActor
public protocol FeedRecordRouter: AnyObject {
    func route(from route: FeedRecordRoute)
}
