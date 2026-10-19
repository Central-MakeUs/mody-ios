//
//  FeedDemoGroupUseCaseStub.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import Foundation
import ModyGroupInterface

struct FeedDemoGroupUseCaseStub: GroupUseCaseProtocol {
    let scenario: FeedDemoScenario

    func createGroup(name: String) async throws -> String {
        try await Task.sleep(for: .milliseconds(500))
        return "DEMO"
    }

    func joinGroup(code: String) async throws {
        try await Task.sleep(for: .milliseconds(500))
    }

    func getGroups() async throws -> [GroupModel] {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .groupFailure { throw NetworkError.invalidResponse }
        if scenario == .noGroups { return [] }
        return [
            GroupModel(groupId: 1, name: "첫 번째 그룹", code: "FEED1", memberCount: 2),
            GroupModel(groupId: 2, name: "두 번째 그룹", code: "FEED2", memberCount: 2)
        ]
    }

    func exitGroup(groupId: Int) async throws {
        try await Task.sleep(for: .milliseconds(500))
    }
}
