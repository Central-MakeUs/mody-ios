//
//  SplashDemoBuilder.swift
//  SplashDemo
//
//  Created by 김동준 on 8/21/26.
//

import SplashInterface
import SwiftUI
import UIKit

@MainActor
struct SplashDemoBuilder: UIViewControllerRepresentable {
    private let builder: SplashBuildable
    private let router: SplashRouter

    init(
        builder: SplashBuildable,
        router: SplashRouter
    ) {
        self.builder = builder
        self.router = router
    }

    func makeUIViewController(context: Context) -> UIViewController {
        builder.makeSplashViewController(router: router)
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {}
}
