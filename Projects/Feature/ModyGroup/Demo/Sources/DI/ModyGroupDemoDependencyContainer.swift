//
//  ModyGroupDemoDependencyContainer.swift
//  ModyGroupDemo
//
//  Created by 김동준 on 10/4/26.
//

import CoreNetworkTesting
import ModyGroup
import ModyGroupInterface

@MainActor
final class ModyGroupDemoDependencyContainer {
    func makeBuilder(for scenario: ModyGroupScenario) -> ModyGroupBuildable {
        ModyGroupBuilder { router, outputHandler in
            let groupUseCase = GroupUseCase(
                groupRepository: GroupRepository(network: CoreNetworkStub { endpoint in
                    try await scenario.networkResponse(to: endpoint)
                })
            )
            return ModyGroupRootFeature(
                groupInviteFeature: GroupInviteFeature(
                    shareGroupInviteUseCase: ModyGroupDemoShareStub(
                        result: scenario.shareResult
                    )
                ),
                groupParticipateFeature: GroupParticipateFeature(
                    groupUseCase: groupUseCase
                ),
                groupCreateFeature: GroupCreateFeature(
                    groupUseCase: groupUseCase
                ),
                output: { output in outputHandler?.handle(output: output) },
                router: { route in router.route(from: route) }
            )
        }
    }
}
