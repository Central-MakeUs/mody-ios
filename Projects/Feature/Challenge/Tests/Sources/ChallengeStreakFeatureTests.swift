//  ChallengeStreakFeatureTests.swift
//  ChallengeTests
//
//  Created by 김동준 on 10/6/26.
//

import CommonDomain
import ComposableArchitecture
import XCTest
@testable import Challenge

@MainActor
final class ChallengeStreakFeatureTests: XCTestCase {
    private let group = GroupModel(groupId: 12, name: "친구들", code: "CODE", memberCount: 7)

    func testEmptyStreakListStopsBeforeSummaryRequest() async {
        let repository = ChallengeFeatureRepositorySpy()
        var state = ChallengeStreakFeature.State()
        state.selectedGroup = group
        let store = TestStore(initialState: state) {
            ChallengeStreakFeature(challengeUseCase: ChallengeUseCase(repository: repository))
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.fetchChallengeNudgeInfo)
        await store.receive(\.challengeNudgeInfoFetched)
        await store.finish()

        XCTAssertEqual(store.state.contentState, .empty)
        XCTAssertNil(store.state.summary)
        let summaryRequestCount = await repository.summaryRequestCount
        XCTAssertEqual(summaryRequestCount, 0)
    }

    func testNudgeMarksMemberAndRejectsRepeatRequest() async {
        let repository = ChallengeFeatureRepositorySpy()
        let member = ChallengeNudgeInfo(
            memberId: 2, nickname: "동규", profileImageUrl: "", recordedToday: false,
            buttonStatus: .available
        )
        var state = ChallengeStreakFeature.State()
        state.selectedGroup = group
        state.nudgeInfos = [member]
        let store = TestStore(initialState: state) {
            ChallengeStreakFeature(challengeUseCase: ChallengeUseCase(repository: repository))
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.nudgeButtonTapped(memberID: 2)) { $0.isNudging = true }
        await store.receive(\.nudgeStarted)
        await store.receive(\.nudgeCompleted)
        XCTAssertEqual(store.state.nudgeInfos?.first?.buttonStatus, .nudged)
        await store.send(.nudgeButtonTapped(memberID: 2))
        await store.finish()

        let requests = await repository.nudgeRequests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first?.groupId, 12)
        XCTAssertEqual(requests.first?.memberId, 2)
    }

    func testNonemptyStreakListFetchesSummary() async {
        let repository = ChallengeFeatureRepositorySpy()
        let member = ChallengeNudgeInfo(
            memberId: 2, nickname: "동규", profileImageUrl: "", recordedToday: false,
            buttonStatus: .available
        )
        await repository.setNudgeInfosResult(.success([member]))
        var state = ChallengeStreakFeature.State()
        state.selectedGroup = group
        let store = TestStore(initialState: state) {
            ChallengeStreakFeature(challengeUseCase: ChallengeUseCase(repository: repository))
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.fetchChallengeNudgeInfo)
        await store.receive(\.challengeNudgeInfoFetched)
        await store.receive(\.fetchChallengeSummary)
        await store.receive(\.challengeSummaryFetched)
        await store.finish()

        XCTAssertEqual(store.state.contentState, .content)
        XCTAssertEqual(store.state.nudgeInfos, [member])
        XCTAssertEqual(store.state.summary?.daysTogether, 10)
        let nudgeRequests = await repository.nudgeInfoRequests
        let summaryCount = await repository.summaryRequestCount
        XCTAssertEqual(nudgeRequests, [12])
        XCTAssertEqual(summaryCount, 1)
    }

    func testNudgeFailureKeepsButtonAvailableAndReportsError() async {
        let repository = ChallengeFeatureRepositorySpy()
        await repository.setNudgeError(.networkUnavailable)
        let member = ChallengeNudgeInfo(
            memberId: 2, nickname: "동규", profileImageUrl: "", recordedToday: false,
            buttonStatus: .available
        )
        var state = ChallengeStreakFeature.State()
        state.selectedGroup = group
        state.nudgeInfos = [member]
        let store = TestStore(initialState: state) {
            ChallengeStreakFeature(challengeUseCase: ChallengeUseCase(repository: repository))
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.nudgeButtonTapped(memberID: 2)) { $0.isNudging = true }
        await store.receive(\.nudgeStarted)
        await store.receive(\.nudgeFailed, .networkUnavailable) {
            $0.isNudging = false
        }
        await store.receive(\.showAlert, .networkUnavailable)
        await store.finish()

        XCTAssertEqual(store.state.nudgeInfos, [member])
        let requests = await repository.nudgeRequests
        XCTAssertEqual(requests.count, 1)
    }
}
