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
        XCTAssertEqual(challenge.title, .seoulIncheon)
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
}
