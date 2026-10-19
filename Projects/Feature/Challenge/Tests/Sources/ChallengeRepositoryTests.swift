//  ChallengeRepositoryTests.swift
//  ChallengeTests
//
//  Created by 김동준 on 10/6/26.
//

import CommonDomain
import CoreNetworkInterface
import Foundation
import XCTest
@testable import Challenge

final class ChallengeRepositoryTests: XCTestCase {
    func testSummaryAndNudgeInfoMapNetworkResponses() async throws {
        let network = ChallengeNetworkSpy()
        let repository = ChallengeRepository(network: network)
        network.json = #"{"result":{"daysTogether":10,"allMemberRecordedDays":5,"hasStartedStreak":true,"monthlyExerciseMinutes":90,"monthlyCompletedChallengeCount":2}}"#

        let summary = try await repository.getChallengeSummary(groupId: 12)

        XCTAssertEqual(summary, ChallengeSummary(
            daysTogether: 10, allMemberRecordedDays: 5, hasStartedStreak: true,
            monthlyExerciseMinutes: 90, monthlyCompletedChallengeCount: 2
        ))
        XCTAssertEqual(network.endpoints.last?.path, "api/v1/groups/12/challenges/summary")
        XCTAssertEqual(network.endpoints.last?.method, .GET)
        XCTAssertEqual(network.endpoints.last?.requiresAuthorization, true)

        network.json = #"{"result":{"members":[{"memberId":2,"nickname":"동규","profileImageUrl":"avatar","recordedToday":false,"buttonStatus":"AVAILABLE"},{"memberId":3,"nickname":"범근","recordedToday":true,"buttonStatus":"UNKNOWN"}]}}"#
        let members = try await repository.getChallengeNudgeInfo(groupId: 12)

        XCTAssertEqual(members, [
            ChallengeNudgeInfo(memberId: 2, nickname: "동규", profileImageUrl: "avatar", recordedToday: false, buttonStatus: .available),
            ChallengeNudgeInfo(memberId: 3, nickname: "범근", profileImageUrl: "", recordedToday: true, buttonStatus: .recorded)
        ])
        XCTAssertEqual(network.endpoints.last?.path, "api/v1/groups/12/challenges/nudges")
        XCTAssertEqual(network.endpoints.last?.method, .GET)
    }

    func testNudgeUsesMemberEndpoint() async throws {
        let network = ChallengeNetworkSpy()
        let repository = ChallengeRepository(network: network)
        network.json = #"{"isSuccess":true,"result":{}}"#

        try await repository.postChallengeNudge(groupId: 12, memberId: 2)

        XCTAssertEqual(network.endpoints.last?.path, "api/v1/groups/12/challenges/nudges/2")
        XCTAssertEqual(network.endpoints.last?.method, .POST)
    }

    func testStepRankingsAndStatusMapServerValues() async throws {
        let network = ChallengeNetworkSpy()
        let repository = ChallengeRepository(network: network)
        network.json = #"{"result":{"rankings":[{"rank":1,"memberId":2,"nickname":"동규","profileImageUrl":"avatar","stepCount":12345}]}}"#

        let rankings = try await repository.getChallengeStepRankings(groupId: 12)

        XCTAssertEqual(rankings, [ChallengeStepRanking(
            rank: 1, memberId: 2, nickname: "동규", profileImageUrl: "avatar", stepCount: 12_345
        )])
        XCTAssertEqual(network.endpoints.last?.path, "api/v1/groups/12/challenges/step/rankings")

        network.json = #"{"result":{"groupChallengeId":34,"title":"서울-인천","targetStepCount":100000,"currentStepCount":25000,"stepCountFetchFromAt":"2026-08-08T07:01:10Z","challengeStatus":"IN_PROGRESS"}}"#
        let status = try await repository.getStepChallengeStatus(groupId: 12)

        XCTAssertEqual(status.groupChallengeId, 34)
        XCTAssertEqual(status.walkChallengeGroup, .seoulIncheon)
        XCTAssertEqual(status.currentStepCount, 25_000)
        XCTAssertFalse(status.isComplete)
        XCTAssertEqual(network.endpoints.last?.path, "api/v1/groups/12/challenges/step/current")
        XCTAssertEqual(network.endpoints.last?.method, .GET)
    }

    func testStepRecordSendsBodyAndRejectsUnsuccessfulResponse() async throws {
        let network = ChallengeNetworkSpy()
        let repository = ChallengeRepository(network: network)
        let request = ChallengeStepCountRequest(recordedOn: "2026-10-06", stepCount: 3_000)
        network.json = #"{"isSuccess":true,"result":{}}"#

        try await repository.postRecordChallengeStepCount(groupId: 12, request: request)

        let endpoint = try XCTUnwrap(network.endpoints.last)
        XCTAssertEqual(endpoint.path, "api/v1/groups/12/challenges/step/records")
        XCTAssertEqual(endpoint.method, .PUT)
        XCTAssertEqual(endpoint.bodyParameters as? ChallengeStepCountRequest, request)

        network.json = #"{"isSuccess":false,"result":{}}"#
        await assertInvalidResponse {
            try await repository.postRecordChallengeStepCount(groupId: 12, request: request)
        }
    }

    func testChangeOptionsAndMutationKeepGroupAndChallengeIDsSeparate() async throws {
        let network = ChallengeNetworkSpy()
        let repository = ChallengeRepository(network: network)
        network.json = #"{"result":{"options":[{"challengeId":7,"title":"서울-인천","departure":"서울","destination":"인천","distanceKm":41.2,"targetStepCount":100000,"selected":false,"completed":false}]}}"#

        let options = try await repository.getChangableChallengeList(groupId: 12)

        XCTAssertEqual(options.count, 1)
        XCTAssertEqual(options.first?.challengeId, 7)
        XCTAssertEqual(network.endpoints.last?.path, "api/v1/groups/12/challenges/step/options")
        network.json = #"{"isSuccess":true,"result":{}}"#

        try await repository.patchStepChallenge(groupId: 12, challengeId: 7)

        let endpoint = try XCTUnwrap(network.endpoints.last)
        XCTAssertEqual(endpoint.path, "api/v1/groups/12/challenges/step/current")
        XCTAssertEqual(endpoint.method, .PATCH)
        let body = try jsonBody(endpoint)
        XCTAssertEqual(body["challengeId"] as? Int, 7)

        network.json = #"{"isSuccess":false,"result":{}}"#
        await assertInvalidResponse {
            try await repository.patchStepChallenge(groupId: 12, challengeId: 7)
        }
    }

    func testWeeklyListDetailAndProofsUseTheirDistinctIDs() async throws {
        let network = ChallengeNetworkSpy()
        let repository = ChallengeRepository(network: network)
        network.json = #"{"result":{"challenges":[{"groupChallengeId":34,"challengeId":7,"title":"함께 걷기","remainingDays":3,"participantCount":1,"randomParticipantNickname":"동규","participants":[],"isComplete":false}]}}"#

        let list = try await repository.getCurrentWeeklyChallenge(groupId: 12)

        XCTAssertEqual(list.first?.groupChallengeId, 34)
        XCTAssertEqual(list.first?.challengeId, 7)
        XCTAssertEqual(network.endpoints.last?.path, "api/v1/groups/12/challenges/weekly")

        network.json = #"{"result":{"challengeId":7,"title":"함께 걷기","description":"걸음","remainingDays":3}}"#
        let detail = try await repository.getWeeklyChallengeDetail(challengeId: 7)

        XCTAssertEqual(detail.challengeId, 7)
        XCTAssertEqual(detail.title, "함께 걷기")
        XCTAssertEqual(network.endpoints.last?.path, "api/v1/weekly-challenges/7")

        network.json = #"{"result":{"proofs":[{"proofId":8,"imageUrl":"image","imageCropRegion":{"x":0.1,"y":0.2,"width":0.7,"height":0.8},"memberId":2,"nickname":"동규"}]}}"#
        let proofs = try await repository.getWeeklyChallengeProofs(groupId: 12, groupChallengeId: 34)

        XCTAssertEqual(proofs.first?.proofId, 8)
        XCTAssertEqual(proofs.first?.imageCropRegion?.width, 0.7)
        XCTAssertEqual(network.endpoints.last?.path, "api/v1/groups/12/weekly-challenges/34/proofs")
        XCTAssertEqual(network.endpoints.last?.method, .GET)
    }

    func testProofCreationAndShareUseGroupChallengeIDAndMapURL() async throws {
        let network = ChallengeNetworkSpy()
        let repository = ChallengeRepository(network: network)
        let request = WeeklyChallengeProofCreateRequest(
            imageKey: "key",
            imageCropRegion: .init(x: 0.1, y: 0.2, width: 0.7, height: 0.8)
        )
        network.json = #"{"isSuccess":true,"result":{}}"#

        try await repository.postWeeklyChallengeProof(groupId: 12, groupChallengeId: 34, request: request)

        let endpoint = try XCTUnwrap(network.endpoints.last)
        XCTAssertEqual(endpoint.path, "api/v1/groups/12/weekly-challenges/34/proofs")
        XCTAssertEqual(endpoint.method, .POST)
        XCTAssertEqual(endpoint.bodyParameters as? WeeklyChallengeProofCreateRequest, request)

        network.json = #"{"isSuccess":false,"result":{}}"#
        await assertInvalidResponse {
            try await repository.postWeeklyChallengeProof(groupId: 12, groupChallengeId: 34, request: request)
        }

        network.json = #"{"result":{"imageUrl":"https://example.invalid/share.jpg"}}"#
        let share = try await repository.postWeeklyChallengeShare(groupId: 12, groupChallengeId: 34)

        XCTAssertEqual(share.imageUrl, "https://example.invalid/share.jpg")
        XCTAssertEqual(network.endpoints.last?.path, "api/v1/groups/12/weekly-challenges/34/share")
        XCTAssertEqual(network.endpoints.last?.method, .POST)
    }

    func testMissingResultsAndInvalidStatusAreRejected() async {
        let network = ChallengeNetworkSpy()
        let repository = ChallengeRepository(network: network)
        network.json = #"{"isSuccess":true}"#
        let fetches: [() async throws -> Void] = [
            { _ = try await repository.getChallengeSummary(groupId: 12) },
            { _ = try await repository.getChallengeNudgeInfo(groupId: 12) },
            { _ = try await repository.getChallengeStepRankings(groupId: 12) },
            { _ = try await repository.getStepChallengeStatus(groupId: 12) },
            { _ = try await repository.getChangableChallengeList(groupId: 12) },
            { _ = try await repository.getCurrentWeeklyChallenge(groupId: 12) },
            { _ = try await repository.getWeeklyChallengeDetail(challengeId: 7) },
            { _ = try await repository.getWeeklyChallengeProofs(groupId: 12, groupChallengeId: 34) },
            { _ = try await repository.postWeeklyChallengeShare(groupId: 12, groupChallengeId: 34) }
        ]
        for fetch in fetches {
            await assertInvalidResponse(fetch)
        }

        network.json = #"{"result":{"title":"UNKNOWN","stepCountFetchFromAt":"2026-08-08T07:01:10Z"}}"#
        await assertInvalidResponse {
            _ = try await repository.getStepChallengeStatus(groupId: 12)
        }
    }

    func testNetworkErrorPropagatesThroughRepository() async {
        let network = ChallengeNetworkSpy()
        network.error = NetworkError.timeout
        let repository = ChallengeRepository(network: network)

        do {
            _ = try await repository.getWeeklyChallengeProofs(groupId: 12, groupChallengeId: 34)
            XCTFail("Expected timeout")
        } catch {
            XCTAssertEqual(error as? NetworkError, .timeout)
        }
        XCTAssertEqual(network.endpoints.count, 1)
    }

    private func assertInvalidResponse(
        _ operation: () async throws -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            try await operation()
            XCTFail("Expected invalid response", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? NetworkError, .invalidResponse, file: file, line: line)
        }
    }

    private func jsonBody(_ endpoint: CoreNetworkEndpoint) throws -> [String: Any] {
        let body = try XCTUnwrap(endpoint.bodyParameters)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(body)) as? [String: Any])
    }
}
