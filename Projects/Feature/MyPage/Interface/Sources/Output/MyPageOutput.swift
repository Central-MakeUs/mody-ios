//
//  MyPageOutput.swift
//  MyPageInterface
//
//  Created by 김동준 on 7/16/26.
//

import CommonDomain

public enum MyPageOutput: Equatable {
    case weightRecordStarted
    case weightRecordSucceeded
    case weightRecordFailed(NetworkError)
    case profileUpdated
}

@MainActor
public protocol MyPageOutputHandler: AnyObject {
    func handle(output: MyPageOutput)
}
