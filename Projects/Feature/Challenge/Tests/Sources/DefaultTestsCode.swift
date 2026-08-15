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
                  "stepCountFetchFromAt": "2026-08-08T07:01:10Z",
                  "challengeStatus": "COMPLETED"
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
        XCTAssertTrue(challenge.isComplete)
    }

    func testChallengeStepCountStatusResponseMapsNonCompletedStatusToFalse() throws {
        let response = try JSONDecoder().decode(
            ChallengeStepCountStatusResponse.self,
            from: Data(
                """
                {
                  "title": "서울-인천",
                  "stepCountFetchFromAt": "2026-08-08T07:01:10Z",
                  "challengeStatus": "IN_PROGRESS"
                }
                """.utf8
            )
        )

        XCTAssertFalse(try XCTUnwrap(response.toDomain()).isComplete)
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

    func testRegionTypeMapsAllServerValues() {
        XCTAssertEqual(RegionType(rawValue: "서울"), .seoul)
        XCTAssertEqual(RegionType(rawValue: "인천"), .incheon)
        XCTAssertEqual(RegionType(rawValue: "천안"), .cheonan)
        XCTAssertEqual(RegionType(rawValue: "대전"), .daejeon)
        XCTAssertEqual(RegionType(rawValue: "대구"), .daegu)
        XCTAssertEqual(RegionType(rawValue: "부산"), .busan)
        XCTAssertEqual(RegionType(rawValue: "제주"), .jeju)
    }

    func testChangableWalkChallengeListResponseMapsSwaggerContract() throws {
        let response = try JSONDecoder().decode(
            ChangableWalkChallengeListResponse.self,
            from: Data(
                """
                {
                  "options": [
                    {
                      "challengeId": 10,
                      "title": "서울-인천",
                      "departure": "서울",
                      "destination": "인천",
                      "distanceKm": 41.2,
                      "targetStepCount": 150000,
                      "selected": true,
                      "completed": false
                    }
                  ]
                }
                """.utf8
            )
        )

        let challenges = try XCTUnwrap(response.toDomain())
        let challenge = try XCTUnwrap(challenges.first)

        XCTAssertEqual(challenges.count, 1)
        XCTAssertEqual(challenge.challengeId, 10)
        XCTAssertEqual(challenge.walkChallengeGroup, .seoulIncheon)
        XCTAssertEqual(challenge.departure, .seoul)
        XCTAssertEqual(challenge.destination, .incheon)
        XCTAssertEqual(challenge.distanceKm, 41.2)
        XCTAssertEqual(challenge.targetStepCount, 150_000)
        XCTAssertTrue(challenge.selected)
        XCTAssertFalse(challenge.completed)
    }

    func testChangableWalkChallengeListResponseMapsUnknownEnumValueToNil() throws {
        let response = try JSONDecoder().decode(
            ChangableWalkChallengeListResponse.self,
            from: Data(
                """
                {
                  "options": [
                    {
                      "title": "서울-인천",
                      "departure": "지원하지 않는 지역",
                      "destination": "인천"
                    }
                  ]
                }
                """.utf8
            )
        )

        XCTAssertNil(response.toDomain())
    }

    func testFetchChangableChallengeListForwardsGroupIdAndReturnsList() async throws {
        let repository = ChallengeRepositorySpy()
        let useCase = ChallengeUseCase(repository: repository)
        let expected = ChangableWalkChallengeModel(
            challengeId: 10,
            walkChallengeGroup: .seoulIncheon,
            departure: .seoul,
            destination: .incheon,
            distanceKm: 41.2,
            targetStepCount: 150_000,
            selected: true,
            completed: false
        )
        repository.changableChallengeList = [expected]

        let result = try await useCase.fetchChangableChallengeList(groupId: 12)

        XCTAssertEqual(repository.changableChallengeGroupId, 12)
        XCTAssertEqual(result, [expected])
    }

    func testGetChangableChallengeListEndpointMatchesSwaggerContract() {
        let endpoint = ChallengeEndpoint.getChangableChallengeList(groupId: 12)

        XCTAssertEqual(endpoint.path, "api/v1/groups/12/challenges/step/options")
        XCTAssertEqual(endpoint.method, .GET)
    }

    func testChangeStepChallengeForwardsGroupIdAndChallengeId() async throws {
        let repository = ChallengeRepositorySpy()
        let useCase = ChallengeUseCase(repository: repository)

        try await useCase.changeStepChallenge(groupId: 12, challengeId: 34)

        XCTAssertEqual(repository.changedGroupId, 12)
        XCTAssertEqual(repository.changedChallengeId, 34)
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

    func testUpdateChallengeStepCountForwardsRequestWithoutConversion() async throws {
        let repository = ChallengeRepositorySpy()
        let useCase = ChallengeUseCase(repository: repository)
        let request = ChallengeStepCountRequest(
            recordedOn: "2026-08-09",
            stepCount: 3_456
        )

        try await useCase.updateChallengeStepCount(
            groupId: 12,
            request: request
        )

        XCTAssertEqual(repository.recordedGroupId, 12)
        XCTAssertEqual(repository.recordedRequest, request)
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

    func testWeeklyChallengeDetailResponseMapsSwaggerContract() throws {
        let response = try JSONDecoder().decode(
            WeeklyChallengeDetailResponse.self,
            from: Data(
                """
                {
                  "challengeId": 34,
                  "title": "하루 물 2L 마시기",
                  "description": "일주일 동안 매일 물 2L를 마셔요.",
                  "remainingDays": 3
                }
                """.utf8
            )
        )

        let detail = response.toDomain()

        XCTAssertEqual(detail.challengeId, 34)
        XCTAssertEqual(detail.title, "하루 물 2L 마시기")
        XCTAssertEqual(detail.description, "일주일 동안 매일 물 2L를 마셔요.")
        XCTAssertEqual(detail.remainingDays, 3)
    }

    func testCurrentWeeklyChallengeListResponseMapsChallengeIds() throws {
        let response = try JSONDecoder().decode(
            CurrentWeeklyChallengeListResponse.self,
            from: Data(
                """
                {
                  "challenges": [
                    {
                      "groupChallengeId": 34,
                      "challengeId": 56,
                      "title": "하루 물 2L 마시기",
                      "remainingDays": 3,
                      "participantCount": 0,
                      "randomParticipantNickname": "",
                      "participants": []
                    }
                  ]
                }
                """.utf8
            )
        )

        let challenge = try XCTUnwrap(response.toDomain().first)

        XCTAssertEqual(challenge.groupChallengeId, 34)
        XCTAssertEqual(challenge.challengeId, 56)
    }

    func testFetchWeeklyChallengeDetailForwardsChallengeId() async throws {
        let repository = ChallengeRepositorySpy()
        let useCase = ChallengeUseCase(repository: repository)
        let expected = WeeklyChallengeDetail(
            challengeId: 34,
            title: "하루 물 2L 마시기",
            description: "일주일 동안 매일 물 2L를 마셔요.",
            remainingDays: 3
        )
        repository.weeklyChallengeDetail = expected

        let result = try await useCase.fetchWeeklyChallengeDetail(challengeId: 34)

        XCTAssertEqual(repository.weeklyChallengeDetailId, 34)
        XCTAssertEqual(result, expected)
    }

    func testGetWeeklyChallengeDetailEndpointMatchesSwaggerContract() {
        let endpoint = ChallengeEndpoint.getWeeklyChallengeDetail(challengeId: 34)

        XCTAssertEqual(endpoint.path, "api/v1/weekly-challenges/34")
        XCTAssertEqual(endpoint.method, .GET)
    }

    func testWeeklyChallengeProofListResponseMapsSwaggerContract() throws {
        let response = try JSONDecoder().decode(
            WeeklyChallengeProofListResponse.self,
            from: Data(
                """
                {
                  "proofs": [
                    {
                      "proofId": 56,
                      "imageUrl": "https://example.com/proofs/56.jpg",
                      "imageCropRegion": {
                        "x": 0.1,
                        "y": 0.2,
                        "width": 0.7,
                        "height": 0.6
                      },
                      "memberId": 78,
                      "nickname": "모디",
                      "profileImageUrl": "https://example.com/profiles/78.jpg"
                    }
                  ]
                }
                """.utf8
            )
        )

        let proofs = response.toDomain()
        let proof = try XCTUnwrap(proofs.first)
        let cropRegion = try XCTUnwrap(proof.imageCropRegion)

        XCTAssertEqual(proofs.count, 1)
        XCTAssertEqual(proof.proofId, 56)
        XCTAssertEqual(proof.imageUrl, "https://example.com/proofs/56.jpg")
        XCTAssertEqual(cropRegion.x, 0.1)
        XCTAssertEqual(cropRegion.y, 0.2)
        XCTAssertEqual(cropRegion.width, 0.7)
        XCTAssertEqual(cropRegion.height, 0.6)
        XCTAssertEqual(proof.memberId, 78)
        XCTAssertEqual(proof.nickname, "모디")
        XCTAssertEqual(proof.profileImageUrl, "https://example.com/profiles/78.jpg")
    }

    func testFetchWeeklyChallengeProofsForwardsIdsAndReturnsList() async throws {
        let repository = ChallengeRepositorySpy()
        let useCase = ChallengeUseCase(repository: repository)
        let expected = WeeklyChallengeImageInfo(
            proofId: 56,
            imageUrl: "https://example.com/proofs/56.jpg",
            imageCropRegion: WeeklyChallengeImageCropRegion(
                x: 0.1,
                y: 0.2,
                width: 0.7,
                height: 0.6
            ),
            memberId: 78,
            nickname: "모디",
            profileImageUrl: "https://example.com/profiles/78.jpg"
        )
        repository.weeklyChallengeProofs = [expected]

        let result = try await useCase.fetchWeeklyChallengeProofs(
            groupId: 12,
            groupChallengeId: 34
        )

        XCTAssertEqual(repository.weeklyChallengeProofsGroupId, 12)
        XCTAssertEqual(repository.weeklyChallengeProofsGroupChallengeId, 34)
        XCTAssertEqual(result, [expected])
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

private final class ChallengeRepositorySpy: ChallengeRepositoryProtocol {
    var changableChallengeList: [ChangableWalkChallengeModel] = []
    var weeklyChallengeProofs: [WeeklyChallengeImageInfo] = []
    var weeklyChallengeDetail = WeeklyChallengeDetail(
        challengeId: -1,
        title: "",
        description: "",
        remainingDays: 0
    )

    private(set) var changableChallengeGroupId: Int?
    private(set) var changedGroupId: Int?
    private(set) var changedChallengeId: Int?
    private(set) var recordedGroupId: Int?
    private(set) var recordedRequest: ChallengeStepCountRequest?
    private(set) var weeklyChallengeDetailId: Int?
    private(set) var weeklyChallengeProofsGroupId: Int?
    private(set) var weeklyChallengeProofsGroupChallengeId: Int?

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

    func getChangableChallengeList(groupId: Int) async throws -> [ChangableWalkChallengeModel] {
        changableChallengeGroupId = groupId
        return changableChallengeList
    }

    func patchStepChallenge(groupId: Int, challengeId: Int) async throws {
        changedGroupId = groupId
        changedChallengeId = challengeId
    }

    func getCurrentWeeklyChallenge(groupId: Int) async throws -> [CurrentWeeklyChallenge] {
        fatalError("Not used in these tests")
    }

    func getWeeklyChallengeDetail(challengeId: Int) async throws -> WeeklyChallengeDetail {
        weeklyChallengeDetailId = challengeId
        return weeklyChallengeDetail
    }

    func getWeeklyChallengeProofs(
        groupId: Int,
        groupChallengeId: Int
    ) async throws -> [WeeklyChallengeImageInfo] {
        weeklyChallengeProofsGroupId = groupId
        weeklyChallengeProofsGroupChallengeId = groupChallengeId
        return weeklyChallengeProofs
    }

    func postWeeklyChallengeProof(
        groupId: Int,
        groupChallengeId: Int,
        request: WeeklyChallengeProofCreateRequest
    ) async throws {
        fatalError("Not used in these tests")
    }

    func postWeeklyChallengeShare(
        groupId: Int,
        groupChallengeId: Int
    ) async throws -> WeeklyChallengeShare {
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
