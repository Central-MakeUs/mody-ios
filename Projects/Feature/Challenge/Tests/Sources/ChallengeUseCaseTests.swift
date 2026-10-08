//  ChallengeUseCaseTests.swift
//  ChallengeTests
//
//  Created by 김동준 on 10/6/26.
//

import Foundation
import XCTest
@testable import Challenge

final class ChallengeUseCaseTests: XCTestCase {
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

    func testChangeStepChallengeForwardsGroupIdAndChallengeId() async throws {
        let repository = ChallengeRepositorySpy()
        let useCase = ChallengeUseCase(repository: repository)

        try await useCase.changeStepChallenge(groupId: 12, challengeId: 34)

        XCTAssertEqual(repository.changedGroupId, 12)
        XCTAssertEqual(repository.changedChallengeId, 34)
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
}
