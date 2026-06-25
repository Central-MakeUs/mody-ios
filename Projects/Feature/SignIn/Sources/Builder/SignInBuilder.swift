//
//  SignInBuilder.swift
//  SignIn
//
//  Created by 김동준 on 6/25/26
//

import UIKit
import SwiftUI
import SignInInterface

public struct SignInBuilder: SignInBuildable {
    public init() {}

    @MainActor
    public func makeSignInViewController(router: SignInRouter) -> UIViewController {
        let view = SignInView()

        return UIHostingController(rootView: view)
    }
}
