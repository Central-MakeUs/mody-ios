//
//  FeedDemoBuilder.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

import FeedInterface
import SwiftUI
import UIKit

@MainActor
struct FeedDemoBuilder: UIViewControllerRepresentable {
    private let makeBuilder: (FeedDemoScenario) -> FeedBuildable
    private let scenario: FeedDemoScenario
    private let router: FeedDemoRouter
    private let outputHandler: FeedDemoOutputHandler

    init(
        makeBuilder: @escaping (FeedDemoScenario) -> FeedBuildable,
        scenario: FeedDemoScenario,
        router: FeedDemoRouter,
        outputHandler: FeedDemoOutputHandler
    ) {
        self.makeBuilder = makeBuilder
        self.scenario = scenario
        self.router = router
        self.outputHandler = outputHandler
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let builder = makeBuilder(scenario)
        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true
        router.attach(
            builder: builder,
            navigationController: navigationController,
            outputHandler: outputHandler
        )
        outputHandler.attach(router: router, navigationController: navigationController)

        let feedViewController = builder.makeFeedViewController(
            router: router,
            outputHandler: outputHandler
        )
        router.setFeedInput(feedViewController as? FeedInputHandler)
        navigationController.setViewControllers([feedViewController], animated: false)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
