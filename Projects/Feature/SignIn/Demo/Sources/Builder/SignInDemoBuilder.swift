//
//  SignInDemoBuilder.swift
//  SignInDemo
//
//  Created by 김동준 on 10/1/26.
//

import SignInInterface
import SwiftUI
import UIKit

@MainActor
struct SignInDemoBuilder: UIViewControllerRepresentable {
    private let builder: SignInBuildable
    private let router: SignInRouter

    init(builder: SignInBuildable, router: SignInRouter) {
        self.builder = builder
        self.router = router
    }

    func makeUIViewController(context: Context) -> UIViewController {
        builder.makeSignInViewController(router: router)
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {}
}
