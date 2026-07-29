//
//  SignInInterface.swift
//  SignInInterface
//
//  Created by 김동준 on 6/25/26
//

import UIKit

public protocol SignInBuildable {
    @MainActor
    func makeSignInViewController(router: SignInRouter) -> UIViewController
}
