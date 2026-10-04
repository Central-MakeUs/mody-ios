//
//  ModyGroupDemoRepositoryStub.swift
//  ModyGroupDemo
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import ModyGroupInterface

struct ModyGroupDemoRepositoryStub: GroupRepositoryProtocol {
    private let scenario: ModyGroupScenario

    init(scenario: ModyGroupScenario) {
        self.scenario = scenario
    }

    func createGroup(name: String) async throws -> String {
        try await Task.sleep(for: .milliseconds(500))
        return try scenario.createResult.get()
    }

    func joinGroup(code: String) async throws {
        try await Task.sleep(for: .milliseconds(500))
        try scenario.joinResult.get()
    }

    func getGroups() async throws -> [GroupModel] { [] }

    func deleteGroup(groupId: Int) async throws {}
}
