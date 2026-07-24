//
//  ModyGroupOutput.swift
//  ModyGroupInterface
//
//  Created by 김동준 on 7/24/26.
//

public enum ModyGroupOutput: Equatable {
    case groupUpdated
}

@MainActor
public protocol ModyGroupOutputHandler: AnyObject {
    func handle(output: ModyGroupOutput)
}
