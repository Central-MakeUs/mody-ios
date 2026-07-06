//
//  AppAssembly+ModyGroup.swift
//  Mody
//
//  Created by 김동준 on 6/26/26
//

import Swinject
import ModyGroupInterface
import ModyGroup

extension AppAssembly {
    func assembleModyGroupFeature(in container: Container) {
        container.register(ModyGroupBuildable.self) { _ in
            return ModyGroupBuilder(
                makeModyGroupRootFeature: { router in
                    ModyGroupRootFeature { [weak router] route in
                        router?.route(from: route)
                    }
                }
            )
        }
    }
}
