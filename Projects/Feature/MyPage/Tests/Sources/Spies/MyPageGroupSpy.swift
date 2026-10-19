//
//  MyPageGroupSpy.swift
//  MyPageTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import ModyGroupInterface

final class MyPageGroupSpy: GroupUseCaseProtocol {
    var groups: [GroupModel] = []
    var error: Error?
    private(set) var fetchCount = 0
    private(set) var exitedIDs: [Int] = []

    func createGroup(name: String) async throws -> String { throw CancellationError() }
    func joinGroup(code: String) async throws { throw CancellationError() }
    func getGroups() async throws -> [GroupModel] {
        fetchCount += 1
        if let error { throw error }
        return groups
    }
    func exitGroup(groupId: Int) async throws {
        exitedIDs.append(groupId)
        if let error { throw error }
    }
}
