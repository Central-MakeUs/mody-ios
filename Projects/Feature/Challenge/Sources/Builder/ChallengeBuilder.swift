//
//  ChallengeBuilder.swift
//  Challenge
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import SwiftUI
import ChallengeInterface

public struct ChallengeBuilder: ChallengeBuildable {
    public init() {}

    @MainActor
    public func makeChallengeViewController(router: ChallengeRouter) -> UIViewController {
        let view = ChallengeView { [weak router] route in
            router?.route(from: route)
        }

        return UIHostingController(rootView: view)
    }
}
