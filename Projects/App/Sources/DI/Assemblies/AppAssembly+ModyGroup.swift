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
        container.register(ModyGroupRootFeature.self) { (resolver: Resolver, router: ModyGroupRouter) in
            return ModyGroupRootFeature { [weak router] route in
                router?.route(from: route)
            }
        }
        
        container.register(ModyGroupBuildable.self) { resolver in
            return ModyGroupBuilder(
                makeModyGroupRootFeature: { router in
                    resolver.resolve(argument: router)
                }
            )
        }
    }
}
