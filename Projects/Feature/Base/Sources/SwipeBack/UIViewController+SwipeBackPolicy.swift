//
//  UIViewController+SwipeBackPolicy.swift
//  Base
//
//  Created by 김동준 on 6/29/26.
//

import ObjectiveC
import UIKit

private enum SwipeBackPolicyAssociatedKey {
    nonisolated(unsafe) static var isSwipeBackEnabled = 0
}

public extension UIViewController {
    var isSwipeBackEnabled: Bool {
        get {
            guard let value = objc_getAssociatedObject(self, &SwipeBackPolicyAssociatedKey.isSwipeBackEnabled) as? Bool else { return true }
            return value
        }
        set {
            objc_setAssociatedObject(
                self,
                &SwipeBackPolicyAssociatedKey.isSwipeBackEnabled,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
