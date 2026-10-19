//
//  MyPageDemoGroupStub.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import ModyGroupInterface

struct MyPageDemoGroupStub: GroupUseCaseProtocol {
    private let scenario: MyPageScenario

    init(scenario: MyPageScenario) {
        self.scenario = scenario
    }

    func createGroup(name: String) async throws -> String { throw CancellationError() }
    func joinGroup(code: String) async throws { throw CancellationError() }

    func getGroups() async throws -> [GroupModel] {
        if scenario == .groupLookupFailure {
            throw NetworkError.networkUnavailable
        }
        let first = GroupModel(groupId: 1, name: "모디 친구들", code: "DEMO01", memberCount: 3)
        if scenario == .lastGroupExit {
            return [first]
        }
        return [first, GroupModel(groupId: 2, name: "운동 친구들", code: "DEMO02", memberCount: 4)]
    }

    func exitGroup(groupId: Int) async throws {
        if scenario == .groupExitFailure {
            throw NetworkError.networkUnavailable
        }
    }
}
