//
//  AppAssembly+ModyGroup.swift
//  Mody
//
//  Created by 김동준 on 6/26/26
//

import Swinject
import CoreKakaoInterface
import CoreNetworkInterface
import ModyGroupInterface
import ModyGroup

extension AppAssembly {
    func assembleModyGroupFeature(in container: Container) {
        container.register(GroupJoinRepositoryProtocol.self) { resolver in
            let network: CoreNetworkProtocol = resolver.resolve()

            return GroupJoinRepository(network: network)
        }

        container.register(GroupJoinUseCase.self) { resolver in
            let repository: GroupJoinRepositoryProtocol = resolver.resolve()

            return GroupJoinUseCase(groupJoinRepository: repository)
        }

        container.register(ShareGroupInviteUseCaseProtocol.self) { resolver in
            let kakaoShareService: CoreKakaoShareInterface = resolver.resolve()

            return ShareGroupInviteUseCase(kakaoShareService: kakaoShareService)
        }

        container.register(ModyGroupBuildable.self) { resolver in
            return ModyGroupBuilder(
                makeModyGroupRootFeature: { router in
                    let shareGroupInviteUseCase: ShareGroupInviteUseCaseProtocol = resolver.resolve()
                    let groupJoinUseCase: GroupJoinUseCase = resolver.resolve()

                    return ModyGroupRootFeature(
                        groupInviteFeature: GroupInviteFeature(
                            shareGroupInviteUseCase: shareGroupInviteUseCase
                        ),
                        groupParticipateFeature: GroupParticipateFeature(
                            groupJoinUseCase: groupJoinUseCase
                        )
                    ) { [weak router] route in
                        router?.route(from: route)
                    }
                }
            )
        }
    }
}
