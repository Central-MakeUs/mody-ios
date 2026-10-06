//  ChallengeEndpointTests.swift
//  ChallengeTests
//
//  Created by 김동준 on 10/6/26.
//

import Foundation
import XCTest
@testable import Challenge

final class ChallengeEndpointTests: XCTestCase {
    func testGetChangableChallengeListEndpointMatchesSwaggerContract() {
        let endpoint = ChallengeEndpoint.getChangableChallengeList(groupId: 12)

        XCTAssertEqual(endpoint.path, "api/v1/groups/12/challenges/step/options")
        XCTAssertEqual(endpoint.method, .GET)
    }

    func testPatchStepChallengeEndpointMatchesSwaggerContract() throws {
        let request = StepChallengeChangeRequest(challengeId: 34)

        let endpoint = ChallengeEndpoint.patchStepChallenge(
            groupId: 12,
            request: request
        )

        XCTAssertEqual(endpoint.path, "api/v1/groups/12/challenges/step/current")
        XCTAssertEqual(endpoint.method, .PATCH)
        XCTAssertEqual(endpoint.bodyParameters as? StepChallengeChangeRequest, request)

        let encodedRequest = try JSONEncoder().encode(request)
        let body = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encodedRequest) as? [String: Any]
        )
        XCTAssertEqual(body.count, 1)
        XCTAssertEqual(body["challengeId"] as? Int, 34)
    }

    func testPutRecordChallengeStepCountEndpointMatchesSwaggerContract() throws {
        let request = ChallengeStepCountRequest(
            recordedOn: "2026-08-09",
            stepCount: 3_456
        )

        let endpoint = ChallengeEndpoint.putRecordChallengeStepCount(
            groupId: 12,
            request: request
        )

        XCTAssertEqual(endpoint.path, "api/v1/groups/12/challenges/step/records")
        XCTAssertEqual(endpoint.method, .PUT)
        XCTAssertEqual(endpoint.bodyParameters as? ChallengeStepCountRequest, request)

        let encodedRequest = try JSONEncoder().encode(request)
        let body = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encodedRequest) as? [String: Any]
        )
        XCTAssertEqual(body.count, 2)
        XCTAssertEqual(body["recordedOn"] as? String, "2026-08-09")
        XCTAssertEqual(body["stepCount"] as? Int, 3_456)
    }

    func testGetWeeklyChallengeDetailEndpointMatchesSwaggerContract() {
        let endpoint = ChallengeEndpoint.getWeeklyChallengeDetail(challengeId: 34)

        XCTAssertEqual(endpoint.path, "api/v1/weekly-challenges/34")
        XCTAssertEqual(endpoint.method, .GET)
    }

    func testGetWeeklyChallengeProofsEndpointMatchesSwaggerContract() {
        let endpoint = ChallengeEndpoint.getWeeklyChallengeProofs(
            groupId: 12,
            groupChallengeId: 34
        )

        XCTAssertEqual(endpoint.path, "api/v1/groups/12/weekly-challenges/34/proofs")
        XCTAssertEqual(endpoint.method, .GET)
    }
}
