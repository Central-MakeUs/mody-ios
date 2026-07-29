//
//  MyPageInput.swift
//  MyPageInterface
//
//  Created by 김동준 on 7/20/26.
//

public enum MyPageInput {
    case profileUpdated
}

@MainActor
public protocol MyPageInputHandler: AnyObject {
    func handle(input: MyPageInput)
}
