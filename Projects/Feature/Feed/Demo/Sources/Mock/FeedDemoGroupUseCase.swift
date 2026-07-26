//
//  FeedDemoGroupUseCase.swift
//  FeedDemo
//
//  Created by 김동준 on 7/22/26.
//

import CommonDomain
import ModyGroupInterface

struct FeedDemoGroupUseCase: GroupUseCaseProtocol {
    func createGroup(name: String) async throws -> String {
        "DEMO"
    }

    func joinGroup(code: String) async throws {}

    func getGroups() async throws -> [GroupModel] {
        try await Task.sleep(nanoseconds: 2_000_000_000)

        return [
            GroupModel(
                groupId: 4537058591744,
                name: "Feed Demo",
                code: "DEMO",
                memberCount: 1
            )
        ]
    }

    func exitGroup(groupId: Int) async throws {}
}
