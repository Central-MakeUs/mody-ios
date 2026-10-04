//
//  GroupUseCaseTests.swift
//  ModyGroupTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import XCTest
@testable import ModyGroup

final class GroupUseCaseTests: XCTestCase {
    func testCreateAndJoinForwardInputsAndResults() async throws {
        let repository = GroupRepositorySpy()
        let useCase = GroupUseCase(groupRepository: repository)

        let code = try await useCase.createGroup(name: "우리 그룹")
        try await useCase.joinGroup(code: code)

        XCTAssertEqual(code, "ABCD1234")
        XCTAssertEqual(repository.createdNames, ["우리 그룹"])
        XCTAssertEqual(repository.joinedCodes, ["ABCD1234"])
    }

    func testGetGroupsAndExitForwardRepositoryContract() async throws {
        let repository = GroupRepositorySpy()
        let groups = [GroupModel(groupId: 42, name: "모디", code: "ABCD1234", memberCount: 3)]
        repository.groupsResult = .success(groups)
        let useCase = GroupUseCase(groupRepository: repository)

        let result = try await useCase.getGroups()
        try await useCase.exitGroup(groupId: 42)

        XCTAssertEqual(result, groups)
        XCTAssertEqual(repository.getGroupsCallCount, 1)
        XCTAssertEqual(repository.exitedGroupIDs, [42])
    }

    func testRepositoryErrorIsPropagated() async {
        let repository = GroupRepositorySpy()
        repository.joinResult = .failure(NetworkError.timeout)
        let useCase = GroupUseCase(groupRepository: repository)

        do {
            try await useCase.joinGroup(code: "BADCODE1")
            XCTFail("Expected timeout")
        } catch {
            XCTAssertEqual(error as? NetworkError, .timeout)
        }
        XCTAssertEqual(repository.joinedCodes, ["BADCODE1"])
    }
}
