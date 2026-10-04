//
//  GroupRepositoryTests.swift
//  ModyGroupTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import CoreNetworkInterface
import XCTest
@testable import ModyGroup

final class GroupRepositoryTests: XCTestCase {
    func testCreatePostsGroupNameAndReturnsCode() async throws {
        let response = GroupCreateResponse(groupId: 42, code: "ABCD1234", name: "우리 그룹")
        let network = GroupNetworkSpy(result: .success(CoreNetworkResponse(result: response)))

        let code = try await GroupRepository(network: network).createGroup(name: "우리 그룹")

        XCTAssertEqual(code, "ABCD1234")
        XCTAssertEqual(network.endpoints.count, 1)
        XCTAssertEqual(network.endpoints.first?.path, "api/v1/groups")
        XCTAssertEqual(network.endpoints.first?.method, .POST)
        XCTAssertEqual(network.endpoints.first?.bodyParameters as? GroupCreateRequest,
                       GroupCreateRequest(name: "우리 그룹"))
    }

    func testCreateRejectsMissingCode() async {
        for code in [nil, ""] as [String?] {
            let response = GroupCreateResponse(groupId: 42, code: code, name: "우리 그룹")
            let network = GroupNetworkSpy(result: .success(CoreNetworkResponse(result: response)))

            do {
                _ = try await GroupRepository(network: network).createGroup(name: "우리 그룹")
                XCTFail("Expected invalid response")
            } catch {
                XCTAssertEqual(error as? NetworkError, .invalidResponse)
            }
        }
    }

    func testJoinPostsInviteCodeAndRequiresResult() async throws {
        let response = GroupJoinResponse(
            groupId: 42, code: "ABCD1234", name: "우리 그룹", memberCount: 2
        )
        let successNetwork = GroupNetworkSpy(result: .success(CoreNetworkResponse(result: response)))

        try await GroupRepository(network: successNetwork).joinGroup(code: "ABCD1234")

        XCTAssertEqual(successNetwork.endpoints.first?.path, "api/v1/groups/join")
        XCTAssertEqual(successNetwork.endpoints.first?.method, .POST)
        XCTAssertEqual(successNetwork.endpoints.first?.bodyParameters as? GroupJoinRequest,
                       GroupJoinRequest(code: "ABCD1234"))

        let missingResultNetwork = GroupNetworkSpy(
            result: .success(CoreNetworkResponse<GroupJoinResponse>(result: nil))
        )
        do {
            try await GroupRepository(network: missingResultNetwork).joinGroup(code: "ABCD1234")
            XCTFail("Expected invalid response")
        } catch {
            XCTAssertEqual(error as? NetworkError, .invalidResponse)
        }
    }

    func testGetGroupsMapsResponseAndRejectsMissingResult() async throws {
        let response = GroupListResponse(groups: [
            GroupItemResponse(groupId: 42, name: "우리 그룹", code: "ABCD1234", memberCount: 3)
        ])
        let network = GroupNetworkSpy(result: .success(CoreNetworkResponse(result: response)))

        let groups = try await GroupRepository(network: network).getGroups()

        XCTAssertEqual(groups, [GroupModel(
            groupId: 42, name: "우리 그룹", code: "ABCD1234", memberCount: 3
        )])
        XCTAssertEqual(network.endpoints.first?.path, "api/v1/groups")
        XCTAssertEqual(network.endpoints.first?.method, .GET)

        let missingResultNetwork = GroupNetworkSpy(
            result: .success(CoreNetworkResponse<GroupListResponse>(result: nil))
        )
        do {
            _ = try await GroupRepository(network: missingResultNetwork).getGroups()
            XCTFail("Expected invalid response")
        } catch {
            XCTAssertEqual(error as? NetworkError, .invalidResponse)
        }
    }

    func testDeleteUsesGroupMemberEndpointAndPropagatesFailure() async throws {
        let network = GroupNetworkSpy(
            result: .success(CoreNetworkResponse(result: CoreNetworkEmptyResponse()))
        )

        try await GroupRepository(network: network).deleteGroup(groupId: 42)

        XCTAssertEqual(network.endpoints.first?.path, "api/v1/groups/42/members/me")
        XCTAssertEqual(network.endpoints.first?.method, .DELETE)

        let failingNetwork = GroupNetworkSpy(result: .failure(NetworkError.timeout))
        do {
            try await GroupRepository(network: failingNetwork).deleteGroup(groupId: 42)
            XCTFail("Expected timeout")
        } catch {
            XCTAssertEqual(error as? NetworkError, .timeout)
        }
    }
}
