//
//  AppAssembly+MyPage.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import MyPageInterface
import MyPage

extension AppAssembly {
    func assembleMyPageFeature(in container: Container) {
        container.register(MyPageFeature.self) { (resolver: Resolver, router: MyPageRouter) in
            return MyPageFeature { [weak router] route in
                router?.route(from: route)
            }
        }

        container.register(MyPageBuildable.self) { resolver in
            return MyPageBuilder(
                makeMyPageFeature: { router in
                    resolver.resolve(argument: router)
                },
                makeProfileFeature: { router in
                    resolver.resolve(argument: router)
                }
            )
        }
    }
}
