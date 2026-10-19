//
//  GroupRepositorySpy.swift
//  ModyGroupTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import ModyGroupInterface

final class GroupRepositorySpy: GroupRepositoryProtocol {
    var createResult: Result<String, Error> = .success("ABCD1234")
    var joinResult: Result<Void, Error> = .success(())
    var groupsResult: Result<[GroupModel], Error> = .success([])
    var exitResult: Result<Void, Error> = .success(())
    private(set) var createdNames: [String] = []
    private(set) var joinedCodes: [String] = []
    private(set) var getGroupsCallCount = 0
    private(set) var exitedGroupIDs: [Int] = []

    func createGroup(name: String) async throws -> String {
        createdNames.append(name)
        return try createResult.get()
    }

    func joinGroup(code: String) async throws {
        joinedCodes.append(code)
        try joinResult.get()
    }

    func getGroups() async throws -> [GroupModel] {
        getGroupsCallCount += 1
        return try groupsResult.get()
    }

    func deleteGroup(groupId: Int) async throws {
        exitedGroupIDs.append(groupId)
        try exitResult.get()
    }
}
