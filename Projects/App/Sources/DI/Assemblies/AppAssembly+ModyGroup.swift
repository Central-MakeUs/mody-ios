//
//  AppAssembly+ModyGroup.swift
//  Mody
//
//  Created by 김동준 on 6/26/26
//

import Swinject
import CoreKakaoInterface
import ModyGroupInterface
import ModyGroup

extension AppAssembly {
    func assembleModyGroupFeature(in container: Container) {
        container.register(ShareGroupInviteUseCaseProtocol.self) { resolver in
            let kakaoShareService: CoreKakaoShareInterface = resolver.resolve()

            return ShareGroupInviteUseCase(kakaoShareService: kakaoShareService)
        }

        container.register(ModyGroupBuildable.self) { resolver in
            return ModyGroupBuilder(
                makeModyGroupRootFeature: { router in
                    let shareGroupInviteUseCase: ShareGroupInviteUseCaseProtocol = resolver.resolve()

                    return ModyGroupRootFeature(
                        groupInviteFeature: GroupInviteFeature(
                            shareGroupInviteUseCase: shareGroupInviteUseCase
                        )
                    ) { [weak router] route in
                        router?.route(from: route)
                    }
                }
            )
        }
    }
}
