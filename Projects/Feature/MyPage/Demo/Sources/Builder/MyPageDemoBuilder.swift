//
//  MyPageDemoBuilder.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import MyPageInterface
import SwiftUI
import UIKit

@MainActor
struct MyPageDemoBuilder: UIViewControllerRepresentable {
    private let scenario: MyPageScenario
    private let onRoute: (String) -> Void
    private let onOutput: (MyPageOutput) -> Void

    init(
        scenario: MyPageScenario,
        onRoute: @escaping (String) -> Void,
        onOutput: @escaping (MyPageOutput) -> Void
    ) {
        self.scenario = scenario
        self.onRoute = onRoute
        self.onOutput = onOutput
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)

        let router = MyPageDemoRouter(onRoute: onRoute, onOutput: onOutput)
        let builder = MyPageDemoDependencyContainer().makeBuilder(for: scenario)
        router.attach(builder: builder, navigationController: navigationController)

        let home = builder.makeMyPageViewController(router: router, outputHandler: router)
        router.setHomeInput(home)
        navigationController.setViewControllers([home], animated: false)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
