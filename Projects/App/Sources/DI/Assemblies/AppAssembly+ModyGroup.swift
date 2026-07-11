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
        container.register(GroupRepositoryProtocol.self) { resolver in
            let network: CoreNetworkProtocol = resolver.resolve()

            return GroupRepository(network: network)
        }

        container.register(GroupUseCase.self) { resolver in
            let repository: GroupRepositoryProtocol = resolver.resolve()

            return GroupUseCase(groupRepository: repository)
        }

        container.register(ShareGroupInviteUseCaseProtocol.self) { resolver in
            let kakaoShareService: CoreKakaoShareInterface = resolver.resolve()

            return ShareGroupInviteUseCase(kakaoShareService: kakaoShareService)
        }

        container.register(ModyGroupBuildable.self) { resolver in
            return ModyGroupBuilder(
                makeModyGroupRootFeature: { router in
                    let shareGroupInviteUseCase: ShareGroupInviteUseCaseProtocol = resolver.resolve()
                    let groupUseCase: GroupUseCase = resolver.resolve()

                    return ModyGroupRootFeature(
                        groupInviteFeature: GroupInviteFeature(
                            shareGroupInviteUseCase: shareGroupInviteUseCase
                        ),
                        groupParticipateFeature: GroupParticipateFeature(
                            groupUseCase: groupUseCase
                        ),
                        groupCreateFeature: GroupCreateFeature(
                            groupUseCase: groupUseCase
                        )
                    ) { [weak router] route in
                        router?.route(from: route)
                    }
                }
            )
        }
    }
}
