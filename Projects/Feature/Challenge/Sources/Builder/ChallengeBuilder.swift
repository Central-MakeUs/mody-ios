//
//  ChallengeBuilder.swift
//  Challenge
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import SwiftUI
import ChallengeInterface
import ComposableArchitecture

public struct ChallengeBuilder: ChallengeBuildable {
    private let makeChallengeFeature: (ChallengeRouter) -> ChallengeFeature

    public init(
        makeChallengeFeature: @escaping (ChallengeRouter) -> ChallengeFeature
    ) {
        self.makeChallengeFeature = makeChallengeFeature
    }

    @MainActor
    public func makeChallengeViewController(router: ChallengeRouter) -> UIViewController {
        let view = ChallengeView(
            store: .init(initialState: .init()) {
                makeChallengeFeature(router)
            }
        )

        return UIHostingController(rootView: view)
    }
}
