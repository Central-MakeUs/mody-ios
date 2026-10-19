//  ChallengeDetailFeatureTests.swift
//  ChallengeTests
//
//  Created by 김동준 on 10/6/26.
//

import CommonDomain
import ComposableArchitecture
import CoreHealthInterface
import Foundation
import XCTest
@testable import Challenge

@MainActor
final class ChallengeDetailFeatureTests: XCTestCase {
    private let group = GroupModel(groupId: 12, name: "친구들", code: "CODE", memberCount: 7)

    func testStepPollingKeepsRankingsVisibleUntilNewValuesArrive() async {
        let repository = ChallengeFeatureRepositorySpy()
        let oldRankings = [ranking(1, member: 1, steps: 2_000), ranking(2, member: 2, steps: 1_900)]
        let newRankings = [ranking(1, member: 2, steps: 3_100), ranking(2, member: 1, steps: 3_000)]
        let updatedStatus = ChallengeStepCountStatus(isComplete: true)
        await repository.setStepResults(rankings: newRankings, status: updatedStatus)

        var state = ChallengeDetailFeature.State()
        state.selectedGroup = group
        state.rankings = oldRankings
        state.stepCountStatus = ChallengeStepCountStatus(isComplete: false)
        let clock = TestClock()
        let store = TestStore(initialState: state) {
            ChallengeDetailFeature(
                challengeUseCase: ChallengeUseCase(repository: repository),
                healthUseCase: ChallengeHealthDummy()
            )
        } withDependencies: {
            $0.continuousClock = clock
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.updateChallengeStepCount(groupID: 12, stepCount: 3_000)) {
            $0.currentStepCountFromHealthKit = 3_000
        }
        XCTAssertEqual(store.state.rankings, oldRankings)
        XCTAssertEqual(store.state.contentState, .content)

        await store.receive(\.challengeStepRankingsFetched)
        await store.receive(\.startMyStepCountTimer)
        await store.receive(\.stepChallengeStatusFetched)
        await store.finish()

        XCTAssertEqual(store.state.rankings, newRankings)
        let updates = await repository.stepUpdates
        XCTAssertEqual(updates.count, 1)
        XCTAssertEqual(updates.first?.groupId, 12)
        XCTAssertEqual(updates.first?.request.stepCount, 3_000)
    }

    func testStepTimerPollsAfterFiveSecondsWithoutResettingChallengeContent() async {
        let repository = ChallengeFeatureRepositorySpy()
        let health = ChallengeHealthSpy(stepCount: 3_000)
        let oldRankings = [ranking(1, member: 1, steps: 2_000), ranking(2, member: 2, steps: 1_900)]
        let newRankings = [ranking(1, member: 2, steps: 3_100), ranking(2, member: 1, steps: 3_000)]
        let weekly = [weeklyChallenge(challengeId: 7, groupChallengeId: 34)]
        await repository.setStepResults(
            rankings: newRankings,
            status: ChallengeStepCountStatus(isComplete: true)
        )

        var state = ChallengeDetailFeature.State()
        state.selectedGroup = group
        state.rankings = oldRankings
        state.stepCountStatus = ChallengeStepCountStatus(stepCountFetchFromAt: .now)
        state.currentWeeklyChallengeList = weekly
        let clock = TestClock()
        let store = TestStore(initialState: state) {
            ChallengeDetailFeature(
                challengeUseCase: ChallengeUseCase(repository: repository),
                healthUseCase: health
            )
        } withDependencies: {
            $0.continuousClock = clock
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.startMyStepCountTimer)
        await clock.advance(by: .seconds(4))
        let earlyReads = await health.stepCountRequestCount
        XCTAssertEqual(earlyReads, 0)
        XCTAssertEqual(store.state.rankings, oldRankings)
        XCTAssertEqual(store.state.currentWeeklyChallengeList, weekly)

        await clock.advance(by: .seconds(1))
        await store.receive(\.fetchMyStepCount)
        await store.receive(\.updateChallengeStepCount)
        await store.receive(\.challengeStepRankingsFetched)
        await store.receive(\.startMyStepCountTimer)
        await store.receive(\.stepChallengeStatusFetched)
        await store.finish()

        let reads = await health.stepCountRequestCount
        XCTAssertEqual(reads, 1)
        XCTAssertEqual(store.state.rankings, newRankings)
        XCTAssertEqual(store.state.currentWeeklyChallengeList, weekly)
        XCTAssertEqual(store.state.contentState, .content)
        let weeklyRequests = await repository.weeklyListRequests
        XCTAssertTrue(weeklyRequests.isEmpty)
    }

    func testChallenge303ShowsEmptyStepChallengeWithoutAlert() async {
        let repository = ChallengeFeatureRepositorySpy()
        await repository.setRankingError(.serverError(
            code: ServerErrorCode.challenge303.code, message: nil, fallback: .badRequest
        ))
        var state = ChallengeDetailFeature.State()
        state.selectedGroup = group
        let store = TestStore(initialState: state) {
            ChallengeDetailFeature(
                challengeUseCase: ChallengeUseCase(repository: repository),
                healthUseCase: ChallengeHealthDummy()
            )
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.fetchChallengeStepRankings)
        await store.receive(\.challengeStepRankingsFetched)
        await store.finish()

        XCTAssertEqual(store.state.rankings, [])
        XCTAssertEqual(store.state.contentState, .empty)
        XCTAssertNil(store.state.currentStepCountFromHealthKit)
    }

    func testChallenge303StatusUsesEmptyDefault() async {
        let repository = ChallengeFeatureRepositorySpy()
        await repository.setStepStatusError(.serverError(
            code: ServerErrorCode.challenge303.code, message: nil, fallback: .badRequest
        ))
        var state = ChallengeDetailFeature.State()
        state.selectedGroup = group
        let store = TestStore(initialState: state) {
            ChallengeDetailFeature(
                challengeUseCase: ChallengeUseCase(repository: repository),
                healthUseCase: ChallengeHealthDummy()
            )
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.fetchStepChallengeStatus)
        await store.receive(\.stepChallengeStatusFetched)
        await store.finish()

        XCTAssertEqual(store.state.stepCountStatus?.groupChallengeId, -1)
        XCTAssertEqual(store.state.stepCountStatus?.currentStepCount, 0)
        let requests = await repository.statusRequests
        XCTAssertEqual(requests, [12])
    }

    func testUnchangedHealthStepCountSkipsServerUpdate() async {
        let repository = ChallengeFeatureRepositorySpy()
        var state = ChallengeDetailFeature.State()
        state.selectedGroup = group
        state.rankings = [ranking(1, member: 1, steps: 3_000), ranking(2, member: 2, steps: 2_900)]
        state.currentStepCountFromHealthKit = 3_000
        let store = TestStore(initialState: state) {
            ChallengeDetailFeature(
                challengeUseCase: ChallengeUseCase(repository: repository),
                healthUseCase: ChallengeHealthDummy()
            )
        }

        await store.send(.updateChallengeStepCount(groupID: 12, stepCount: 3_000))
        await store.finish()

        XCTAssertEqual(store.state.rankings, state.rankings)
        let updates = await repository.stepUpdates
        XCTAssertTrue(updates.isEmpty)
    }

    func testStepUpdateFailureLeavesCurrentRankingsVisible() async {
        let repository = ChallengeFeatureRepositorySpy()
        await repository.setStepUpdateError(.networkUnavailable)
        var state = ChallengeDetailFeature.State()
        state.selectedGroup = group
        state.rankings = [ranking(1, member: 1, steps: 2_000), ranking(2, member: 2, steps: 1_900)]
        state.stepCountStatus = ChallengeStepCountStatus(isComplete: false)
        let store = TestStore(initialState: state) {
            ChallengeDetailFeature(
                challengeUseCase: ChallengeUseCase(repository: repository),
                healthUseCase: ChallengeHealthDummy()
            )
        }

        await store.send(.updateChallengeStepCount(groupID: 12, stepCount: 3_000)) {
            $0.currentStepCountFromHealthKit = 3_000
        }
        await store.finish()

        XCTAssertEqual(store.state.rankings, state.rankings)
        XCTAssertEqual(store.state.contentState, .content)
        let updates = await repository.stepUpdates
        let rankingRequests = await repository.rankingRequests
        let statusRequests = await repository.statusRequests
        XCTAssertEqual(updates.count, 1)
        XCTAssertTrue(rankingRequests.isEmpty)
        XCTAssertTrue(statusRequests.isEmpty)
    }

    func testWeeklyChallengeRefreshReplacesListWithoutClearingRankings() async {
        let repository = ChallengeFeatureRepositorySpy()
        let updated = weeklyChallenge(challengeId: 8, groupChallengeId: 35)
        await repository.setWeeklyList([updated])
        var state = ChallengeDetailFeature.State()
        state.selectedGroup = group
        state.rankings = [ranking(1, member: 1, steps: 3_000), ranking(2, member: 2, steps: 2_000)]
        state.currentWeeklyChallengeList = [weeklyChallenge(challengeId: 7, groupChallengeId: 34)]
        let store = TestStore(initialState: state) {
            ChallengeDetailFeature(
                challengeUseCase: ChallengeUseCase(repository: repository),
                healthUseCase: ChallengeHealthDummy()
            )
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.refreshCurrentWeeklyChallenge) {
            $0.currentWeeklyChallengeList = nil
        }
        XCTAssertEqual(store.state.rankings, state.rankings)
        await store.receive(\.currentWeeklyChallengeListFetched)
        await store.finish()

        XCTAssertEqual(store.state.currentWeeklyChallengeList, [updated])
        let requests = await repository.weeklyListRequests
        XCTAssertEqual(requests, [12])
    }

    func testPreviousGroupResponsesCannotReplaceSelectedGroupData() async {
        let repository = ChallengeFeatureRepositorySpy()
        var state = ChallengeDetailFeature.State()
        state.selectedGroup = group
        state.rankings = [ranking(1, member: 1, steps: 3_000)]
        state.stepCountStatus = ChallengeStepCountStatus(groupChallengeId: 34)
        state.currentWeeklyChallengeList = [weeklyChallenge(challengeId: 7, groupChallengeId: 34)]
        let store = TestStore(initialState: state) {
            ChallengeDetailFeature(
                challengeUseCase: ChallengeUseCase(repository: repository),
                healthUseCase: ChallengeHealthDummy()
            )
        }

        await store.send(.challengeStepRankingsFetched(groupID: 99, [ranking(1, member: 2, steps: 9_000)]))
        await store.send(.stepChallengeStatusFetched(groupID: 99, ChallengeStepCountStatus(groupChallengeId: 99)))
        await store.send(.currentWeeklyChallengeListFetched(
            groupID: 99, [weeklyChallenge(challengeId: 9, groupChallengeId: 99)]
        ))

        XCTAssertEqual(store.state.rankings, state.rankings)
        XCTAssertEqual(store.state.stepCountStatus, state.stepCountStatus)
        XCTAssertEqual(store.state.currentWeeklyChallengeList, state.currentWeeklyChallengeList)
    }

    private func ranking(_ rank: Int, member: Int, steps: Int) -> ChallengeStepRanking {
        ChallengeStepRanking(
            rank: rank, memberId: member, nickname: "멤버 \(member)",
            profileImageUrl: "", stepCount: steps
        )
    }

    private func weeklyChallenge(challengeId: Int, groupChallengeId: Int) -> CurrentWeeklyChallenge {
        CurrentWeeklyChallenge(
            groupChallengeId: groupChallengeId, challengeId: challengeId, title: "걷기",
            remainingDays: 3, participantCount: 0,
            randomParticipantNickname: "", participants: [], isComplete: false
        )
    }
}

private actor ChallengeHealthSpy: HealthUseCaseProtocol {
    private let stepCount: Int
    private(set) var stepCountRequestCount = 0

    init(stepCount: Int) {
        self.stepCount = stepCount
    }

    func getStepCount(from startDate: Date, to endDate: Date) async throws -> Int {
        stepCountRequestCount += 1
        return stepCount
    }

    func getCurrentMonthStepCount() async throws -> Int {
        XCTFail("Unexpected monthly HealthKit request")
        return 0
    }
}
