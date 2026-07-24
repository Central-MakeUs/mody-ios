//
//  FeedInput.swift
//  FeedInterface
//
//  Created by 김동준 on 7/24/26.
//

public enum FeedInput {
    case refreshGroups
}

@MainActor
public protocol FeedInputHandler: AnyObject {
    func handle(input: FeedInput)
}
