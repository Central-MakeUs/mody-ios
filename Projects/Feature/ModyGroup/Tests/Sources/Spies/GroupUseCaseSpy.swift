//
//  GroupUseCaseSpy.swift
//  ModyGroupTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import ModyGroupInterface

final class GroupUseCaseSpy: GroupUseCaseProtocol {
    var createResult: Result<String, Error> = .success("ABCD1234")
    var joinResult: Result<Void, Error> = .success(())
    private(set) var createdNames: [String] = []
    private(set) var joinedCodes: [String] = []

    func createGroup(name: String) async throws -> String {
        createdNames.append(name)
        return try createResult.get()
    }

    func joinGroup(code: String) async throws {
        joinedCodes.append(code)
        try joinResult.get()
    }

    func getGroups() async throws -> [GroupModel] {
        throw NetworkError.unknown
    }

    func exitGroup(groupId: Int) async throws {
        throw NetworkError.unknown
    }
}
