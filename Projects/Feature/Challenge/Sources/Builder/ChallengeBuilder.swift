//
//  ChallengeBuilder.swift
//  Challenge
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import ChallengeInterface
import ComposableArchitecture

public struct ChallengeBuilder: ChallengeBuildable {
    private let makeChallengeFeature: (ChallengeRouter, ChallengeOutputHandler) -> ChallengeFeature

    public init(
        makeChallengeFeature: @escaping (ChallengeRouter, ChallengeOutputHandler) -> ChallengeFeature
    ) {
        self.makeChallengeFeature = makeChallengeFeature
    }

    @MainActor
    public func makeChallengeViewController(
        router: ChallengeRouter,
        outputHandler: ChallengeOutputHandler
    ) -> UIViewController {
        let store: StoreOf<ChallengeFeature> = .init(initialState: .init()) {
            makeChallengeFeature(router, outputHandler)
        }

        return ChallengeHostingController(store: store)
    }
}
