//
//  FeedInput.swift
//  FeedInterface
//
//  Created by 김동준 on 7/22/26.
//

public enum FeedInput {
    case recordCreated
}

@MainActor
public protocol FeedInputHandler: AnyObject {
    func handle(input: FeedInput)
}
