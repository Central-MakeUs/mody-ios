//
//  SwipeBackEvent.swift
//  Base
//
//  Created by 김동준 on 6/29/26.
//

@MainActor
public protocol SwipeBackEventReceivable: AnyObject {
    func swipeBackDidComplete()
    func swipeBackDidCancel()
}
