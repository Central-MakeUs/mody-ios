//
//  OnBoardingDemoBuilder.swift
//  OnBoardingDemo
//
//  Created by 김동준 on 10/4/26.
//

import OnBoardingInterface
import SwiftUI
import UIKit

@MainActor
struct OnBoardingDemoBuilder: UIViewControllerRepresentable {
    private let builder: OnBoardingBuildable
    private let router: OnBoardingRouter

    init(builder: OnBoardingBuildable, router: OnBoardingRouter) {
        self.builder = builder
        self.router = router
    }

    func makeUIViewController(context: Context) -> UIViewController {
        builder.makeOnBoardingViewController(router: router)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
