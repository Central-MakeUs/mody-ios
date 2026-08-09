import Foundation
import XCTest
@testable import Challenge

final class ChallengeTests: XCTestCase {
    func testWalkChallengeRequiredGroupMapsAllServerValues() {
        XCTAssertEqual(WalkChallengeRequiredGroup(rawValue: "서울-인천"), .seoulIncheon)
        XCTAssertEqual(WalkChallengeRequiredGroup(rawValue: "서울-천안"), .seoulCheonan)
        XCTAssertEqual(WalkChallengeRequiredGroup(rawValue: "서울-대전"), .seoulDaejeon)
        XCTAssertEqual(WalkChallengeRequiredGroup(rawValue: "서울-대구"), .seoulDaegu)
        XCTAssertEqual(WalkChallengeRequiredGroup(rawValue: "서울-부산"), .seoulBusan)
        XCTAssertEqual(WalkChallengeRequiredGroup(rawValue: "서울-제주"), .seoulJeju)
    }

    func testChallengeStepCountStatusResponseMapsISO8601DateAndKnownTitle() throws {
        let response = try JSONDecoder().decode(
            ChallengeStepCountStatusResponse.self,
            from: Data(
                """
                {
                  "groupChallengeId": 1,
                  "title": "서울-인천",
                  "targetStepCount": 100000,
                  "currentStepCount": 25000,
                  "stepCountFetchFromAt": "2026-08-08T07:01:10Z"
                }
                """.utf8
            )
        )

        let challenge = try XCTUnwrap(response.toDomain())

        XCTAssertEqual(challenge.groupChallengeId, 1)
        XCTAssertEqual(challenge.walkChallengeGroup, .seoulIncheon)
        XCTAssertEqual(challenge.targetStepCount, 100000)
        XCTAssertEqual(challenge.currentStepCount, 25000)
        XCTAssertEqual(challenge.stepCountFetchFromAt.timeIntervalSince1970, 1_786_172_470)
    }

    func testChallengeStepCountStatusResponseMapsUnknownTitleToNil() throws {
        let response = try JSONDecoder().decode(
            ChallengeStepCountStatusResponse.self,
            from: Data(
                """
                {
                  "title": "지원하지 않는 챌린지",
                  "stepCountFetchFromAt": "2026-08-08T07:01:10.123Z"
                }
                """.utf8
            )
        )

        XCTAssertNil(response.toDomain())
    }

    func testChallengeStepCountStatusResponseMapsMissingTitleToNil() throws {
        let response = try JSONDecoder().decode(
            ChallengeStepCountStatusResponse.self,
            from: Data(
                """
                {
                  "stepCountFetchFromAt": "2026-08-08T07:01:10.123Z"
                }
                """.utf8
            )
        )

        XCTAssertNil(response.toDomain())
    }

    func testUpdateChallengeStepCountUsesRecordedOnWithoutConversion() async throws {
        let repository = ChallengeRepositorySpy()
        let useCase = ChallengeUseCase(repository: repository)

        try await useCase.updateChallengeStepCount(
            groupId: 12,
            recordedOn: "2026-08-09",
            stepCount: 3_456
        )

        XCTAssertEqual(repository.recordedGroupId, 12)
        XCTAssertEqual(repository.recordedRequest?.recordedOn, "2026-08-09")
        XCTAssertEqual(repository.recordedRequest?.stepCount, 3_456)
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
}

private final class ChallengeRepositorySpy: ChallengeRepositoryProtocol {
    private(set) var recordedGroupId: Int?
    private(set) var recordedRequest: ChallengeStepCountRequest?

    func getChallengeSummary(groupId: Int) async throws -> ChallengeSummary {
        fatalError("Not used in these tests")
    }

    func getChallengeNudgeInfo(groupId: Int) async throws -> [ChallengeNudgeInfo] {
        fatalError("Not used in these tests")
    }

    func postChallengeNudge(groupId: Int, memberId: Int) async throws {
        fatalError("Not used in these tests")
    }

    func getChallengeStepRankings(groupId: Int) async throws -> [ChallengeStepRanking] {
        fatalError("Not used in these tests")
    }

    func getStepChallengeStatus(groupId: Int) async throws -> ChallengeStepCountStatus {
        fatalError("Not used in these tests")
    }

    func postRecordChallengeStepCount(
        groupId: Int,
        request: ChallengeStepCountRequest
    ) async throws {
        recordedGroupId = groupId
        recordedRequest = request
    }
}
