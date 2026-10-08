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
    private let makeBuilder: (ChallengeDemoScenario, ChallengeDemoData) -> ChallengeBuildable
    private let scenario: ChallengeDemoScenario
    private let simulationTick: Int
    private let router: ChallengeDemoRouter

    init(
        makeBuilder: @escaping (ChallengeDemoScenario, ChallengeDemoData) -> ChallengeBuildable,
        scenario: ChallengeDemoScenario,
        simulationTick: Int,
        router: ChallengeDemoRouter
    ) {
        self.makeBuilder = makeBuilder
        self.scenario = scenario
        self.simulationTick = simulationTick
        self.router = router
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(simulationTick: simulationTick)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)

        let builder = makeBuilder(scenario, context.coordinator.data)
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
        let data = ChallengeDemoData()
        let clock = TestClock()
        var appliedTick: Int

        init(simulationTick: Int) {
            appliedTick = simulationTick
        }
    }
}
