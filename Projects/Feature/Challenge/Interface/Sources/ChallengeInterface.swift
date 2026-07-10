//
//  ChallengeInterface.swift
//  ChallengeInterface
//
//  Created by 김동준 on 6/30/26
//

import UIKit

public protocol ChallengeBuildable {
    @MainActor
    func makeChallengeViewController(router: ChallengeRouter) -> UIViewController
}
