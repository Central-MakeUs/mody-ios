//
//  SwiftUIAlertSwipeBackPolicy.swift
//  Base
//
//  Created by 김동준 on 7/20/26.
//

import Foundation

@MainActor
public final class SwiftUIAlertSwipeBackPolicy {
    public static let shared = SwiftUIAlertSwipeBackPolicy()

    public private(set) var isAlertPresented = false

    private init() {}

    public func setAlertPresented(_ isPresented: Bool) {
        isAlertPresented = isPresented
    }
}
