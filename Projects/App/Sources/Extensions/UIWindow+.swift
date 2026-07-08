//
//  UIWindow+.swift
//  Mody
//
//  Created by 김동준 on 7/8/26.
//

import UIKit

extension UIWindow {
    func addKeyboardDismissTapGestureRecognizer() {
        let gestureName = "Mody.KeyboardDismissTapGesture"

        guard gestureRecognizers?.contains(where: { $0.name == gestureName }) != true else {
            return
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing))
        tapGesture.name = gestureName
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
}
