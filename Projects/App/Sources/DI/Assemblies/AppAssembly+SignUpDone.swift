//
//  AppAssembly+SignUpDone.swift
//  Mody
//
//  Created by 김동준 on 6/26/26
//

import Swinject
import SignUpDoneInterface
import SignUpDone

extension AppAssembly {
    func assembleSignUpDoneFeature(in container: Container) {
        container.register(SignUpDoneRootFeature.self) { (resolver: Resolver, router: SignUpDoneRouter) in
            return SignUpDoneRootFeature { [weak router] route in
                router?.route(from: route)
            }
        }
        
        container.register(SignUpDoneBuildable.self) { resolver in
            return SignUpDoneBuilder(
                makeSignUpDoneRootFeature: { router in
                    resolver.resolve(argument: router)
                }
            )
        }
    }
}
