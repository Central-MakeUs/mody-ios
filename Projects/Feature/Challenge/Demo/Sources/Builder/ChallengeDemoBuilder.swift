//
//  ChallengeDemoBuilder.swift
//  ChallengeDemo
//
//  Created by 김동준 on 10/5/26.
//

import ChallengeInterface
import CommonDomain
import ComposableArchitecture
import SwiftUI
import UIKit

@MainActor
struct ChallengeDemoBuilder: UIViewControllerRepresentable {
    private let scenario: ChallengeDemoScenario
    private let simulationTick: Int
    private let onRoute: (String) -> Void
    private let onOutput: (String) -> Void

    init(
        scenario: ChallengeDemoScenario,
        simulationTick: Int,
        onRoute: @escaping (String) -> Void,
        onOutput: @escaping (String) -> Void
    ) {
        self.scenario = scenario
        self.simulationTick = simulationTick
        self.onRoute = onRoute
        self.onOutput = onOutput
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            router: ChallengeDemoRouter(onRoute: onRoute, onOutput: onOutput),
            simulationTick: simulationTick
        )
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)

        let router = context.coordinator.router
        let builder = ChallengeDemoDependencyContainer().makeBuilder(
            for: scenario, data: context.coordinator.data
        )
        router.attach(builder: builder, navigationController: navigationController)

        let home: UIViewController
        if scenario == .stepCompetition || scenario == .stepLive {
            home = withDependencies {
                $0.continuousClock = context.coordinator.clock
            } operation: {
                builder.makeChallengeViewController(router: router, outputHandler: router)
            }
        } else {
            home = builder.makeChallengeViewController(router: router, outputHandler: router)
        }
        navigationController.setViewControllers([home], animated: false)
        if let input = home as? ChallengeInputHandler {
            router.setHomeInput(input)
            input.handle(input: .selectedGroupUpdated(GroupModel(
                groupId: 1, name: "데모 그룹", code: "DEMO", memberCount: 7
            )))
            if scenario == .challengeEmpty || scenario == .stepCompetition || scenario == .stepLive {
                input.handle(input: .challengeDetailRequested)
            }
        }
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard simulationTick > context.coordinator.appliedTick else { return }
        context.coordinator.appliedTick = simulationTick
        let data = context.coordinator.data
        let clock = context.coordinator.clock
        Task {
            await data.advance(to: simulationTick)
            await clock.advance(by: .seconds(5))
        }
    }

    final class Coordinator {
        let router: ChallengeDemoRouter
        let data = ChallengeDemoData()
        let clock = TestClock()
        var appliedTick: Int

        init(router: ChallengeDemoRouter, simulationTick: Int) {
            self.router = router
            appliedTick = simulationTick
        }
    }
}
