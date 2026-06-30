//
//  AppAssembly+Challenge.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import ChallengeInterface
import Challenge

extension AppAssembly {
    func assembleChallengeFeature(in container: Container) {
        container.register(ChallengeBuildable.self) { _ in
            return ChallengeBuilder()
        }
    }
}
