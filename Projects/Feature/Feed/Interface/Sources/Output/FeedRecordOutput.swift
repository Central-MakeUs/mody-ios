//
//  FeedRecordOutput.swift
//  FeedInterface
//
//  Created by 김동준 on 7/22/26.
//

public enum FeedRecordOutput: Equatable {
    case recordCreated
}

@MainActor
public protocol FeedRecordOutputHandler: AnyObject {
    func handle(output: FeedRecordOutput)
}
