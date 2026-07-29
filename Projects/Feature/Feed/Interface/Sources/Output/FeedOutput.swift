//
//  FeedOutput.swift
//  FeedInterface
//
//  Created by 김동준 on 7/29/26.
//

import CommonDomain

public enum FeedOutput: Equatable {
    case reportConfirmationRequested(recordId: Int)
    case reportSucceeded
    case reportFailed(NetworkError)
}

@MainActor
public protocol FeedOutputHandler: AnyObject {
    func handle(output: FeedOutput)
}
