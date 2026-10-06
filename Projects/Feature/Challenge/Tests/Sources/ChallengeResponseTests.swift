//  ChallengeResponseTests.swift
//  ChallengeTests
//
//  Created by 김동준 on 10/6/26.
//

import Foundation
import XCTest
@testable import Challenge

final class ChallengeResponseTests: XCTestCase {
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

    func testChangableWalkChallengeListResponseSkipsUnknownEnumValue() throws {
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

        XCTAssertEqual(response.toDomain(), [])
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
}
