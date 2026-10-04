//
//  ModyGroupDemoBuilder.swift
//  ModyGroupDemo
//
//  Created by 김동준 on 10/4/26.
//

import ModyGroupInterface
import SwiftUI
import UIKit

@MainActor
struct ModyGroupDemoBuilder: UIViewControllerRepresentable {
    private let builder: ModyGroupBuildable
    private let scenario: ModyGroupScenario
    private let router: ModyGroupRouter
    private let outputHandler: ModyGroupOutputHandler

    init(
        builder: ModyGroupBuildable,
        scenario: ModyGroupScenario,
        router: ModyGroupRouter,
        outputHandler: ModyGroupOutputHandler
    ) {
        self.builder = builder
        self.scenario = scenario
        self.router = router
        self.outputHandler = outputHandler
    }

    func makeUIViewController(context: Context) -> UIViewController {
        builder.makeModyGroupViewController(
            entryPoint: scenario.entryPoint,
            showSignUpDoneContents: scenario.showSignUpDoneContents,
            initialScreen: scenario.initialScreen,
            router: router,
            outputHandler: outputHandler
        )
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
