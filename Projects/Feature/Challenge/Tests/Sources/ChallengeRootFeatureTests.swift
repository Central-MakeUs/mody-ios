//  ChallengeRootFeatureTests.swift
//  ChallengeTests
//
//  Created by 김동준 on 10/6/26.
//

import ChallengeInterface
import CommonDomain
import ComposableArchitecture
import XCTest
@testable import Challenge

@MainActor
final class ChallengeRootFeatureTests: XCTestCase {
    private let group = GroupModel(groupId: 12, name: "친구들", code: "CODE", memberCount: 7)

    func testSelectedGroupInputLoadsBothTabsForSameGroup() async {
        let repository = ChallengeFeatureRepositorySpy()
        let store = makeStore(repository: repository)
        store.exhaustivity = .off(showSkippedAssertions: false)

        let selectedGroup = group
        await store.send(.input(.selectedGroupUpdated(selectedGroup))) {
            $0.selectedGroup = selectedGroup
        }
        await store.finish()
        await store.skipReceivedActions(strict: false)

        XCTAssertEqual(store.state.challengeStreak.selectedGroup, group)
        XCTAssertEqual(store.state.challengeDetail.selectedGroup, group)
        XCTAssertEqual(store.state.challengeStreak.contentState, .empty)
        XCTAssertEqual(store.state.challengeDetail.contentState, .empty)
        let nudgeRequests = await repository.nudgeInfoRequests
        let rankingRequests = await repository.rankingRequests
        let statusRequests = await repository.statusRequests
        let weeklyRequests = await repository.weeklyListRequests
        XCTAssertEqual(nudgeRequests, [12])
        XCTAssertEqual(rankingRequests, [12])
        XCTAssertEqual(statusRequests, [12])
        XCTAssertEqual(weeklyRequests, [12])
    }

    func testChangeAndWeeklyRoutesRequireSelectedGroupAndMatchingChallenge() async {
        let repository = ChallengeFeatureRepositorySpy()
        var routes: [ChallengeRoute] = []
        let emptyStore = makeStore(repository: repository, router: { routes.append($0) })
        await emptyStore.send(.challengeDetail(.changeChallengeButtonTapped))
        await emptyStore.send(.challengeDetail(.weeklyChallengeTapped(challengeId: 7, groupChallengeId: 34)))
        XCTAssertTrue(routes.isEmpty)

        var state = ChallengeFeature.State()
        state.selectedGroup = group
        state.challengeDetail.currentWeeklyChallengeList = [weeklyChallenge]
        let store = makeStore(state: state, repository: repository, router: { routes.append($0) })

        await store.send(.challengeDetail(.weeklyChallengeTapped(challengeId: 7, groupChallengeId: 99)))
        await store.send(.challengeDetail(.weeklyChallengeTapped(challengeId: 99, groupChallengeId: 34)))
        XCTAssertTrue(routes.isEmpty)

        await store.send(.challengeDetail(.changeChallengeButtonTapped)).finish()
        await store.send(.challengeDetail(.weeklyChallengeTapped(challengeId: 7, groupChallengeId: 34))).finish()
        XCTAssertEqual(routes, [
            .routeToChallengeChange(groupId: 12),
            .routeToWeeklyDetail(groupId: 12, challengeId: 7, groupChallengeId: 34)
        ])
    }

    func testChildEventsForwardNudgeAndErrorsToOutput() async {
        let repository = ChallengeFeatureRepositorySpy()
        var outputs: [ChallengeOutput] = []
        let store = makeStore(repository: repository, output: { outputs.append($0) })

        await store.send(.challengeStreak(.nudgeStarted)).finish()
        await store.send(.challengeStreak(.nudgeCompleted(groupID: 12, memberID: 2, nickname: "동규"))).finish()
        await store.send(.challengeStreak(.showAlert(.networkUnavailable))).finish()
        await store.send(.challengeDetail(.showAlert(.timeout))).finish()

        XCTAssertEqual(outputs, [
            .nudgeStarted,
            .nudgeSucceeded(nickname: "동규"),
            .showAlert(.networkUnavailable),
            .showAlert(.timeout)
        ])
    }

    func testChallengeDetailInputSelectsChallengeTab() async {
        let store = makeStore(repository: ChallengeFeatureRepositorySpy())

        await store.send(.input(.challengeDetailRequested)) {
            $0.selectedTab = .challenge
        }
    }

    private var weeklyChallenge: CurrentWeeklyChallenge {
        CurrentWeeklyChallenge(
            groupChallengeId: 34, challengeId: 7, title: "걷기",
            remainingDays: 3, participantCount: 0,
            randomParticipantNickname: "", participants: [], isComplete: false
        )
    }

    private func makeStore(
        state: ChallengeFeature.State = .init(),
        repository: ChallengeFeatureRepositorySpy,
        router: @escaping @MainActor (ChallengeRoute) -> Void = { _ in },
        output: @escaping @MainActor (ChallengeOutput) -> Void = { _ in }
    ) -> TestStoreOf<ChallengeFeature> {
        TestStore(initialState: state) {
            ChallengeFeature(
                challengeUseCase: ChallengeUseCase(repository: repository),
                healthUseCase: ChallengeHealthDummy(),
                router: router,
                output: output
            )
        }
    }
}
