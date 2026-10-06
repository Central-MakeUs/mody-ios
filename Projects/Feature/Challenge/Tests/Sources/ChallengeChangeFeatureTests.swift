//  ChallengeChangeFeatureTests.swift
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
final class ChallengeChangeFeatureTests: XCTestCase {
    func testOnAppearLoadsChangeOptionsForGroup() async {
        let repository = ChallengeFeatureRepositorySpy()
        let options = [option(id: 7), option(id: 8, selected: true)]
        await repository.setChangeOptions(options)
        let store = makeStore(repository: repository)

        await store.send(.onAppear) { $0.isLoading = true }
        await store.receive(\.changableChallengeListFetched, options) {
            $0.isLoading = false
            $0.changableChallengeList = options
        }
        await store.finish()

        let requests = await repository.changeListRequests
        XCTAssertEqual(requests, [12])
    }

    func testOnlyAvailableOptionOpensConfirmation() async {
        let repository = ChallengeFeatureRepositorySpy()
        var state = ChallengeChangeFeature.State(groupId: 12)
        state.changableChallengeList = [
            option(id: 7, selected: true),
            option(id: 8, completed: true),
            option(id: 9)
        ]
        let store = makeStore(state: state, repository: repository)
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.challengeCardTapped(challengeId: 7))
        await store.send(.challengeCardTapped(challengeId: 8))
        XCTAssertNil(store.state.alertCase)

        await store.send(.challengeCardTapped(challengeId: 9)) {
            $0.alertCase = .changeConfirmation(challengeId: 9)
            $0.alertState.dismissOnScrimTap = false
        }
        await store.receive(\.alertAction)
        await store.finish()

        XCTAssertEqual(store.state.alertCase, .changeConfirmation(challengeId: 9))
        XCTAssertTrue(store.state.alertState.isPresented)
        let requests = await repository.changeRequests
        XCTAssertTrue(requests.isEmpty)
    }

    func testConfirmedChangeEmitsOutputAndReturns() async {
        let repository = ChallengeFeatureRepositorySpy()
        var outputs: [ChallengeOutput] = []
        var routes: [ChallengeChangeRoute] = []
        var state = ChallengeChangeFeature.State(groupId: 12)
        state.changableChallengeList = [option(id: 7)]
        let store = makeStore(
            state: state, repository: repository,
            router: { routes.append($0) }, output: { outputs.append($0) }
        )
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.challengeChangeConfirmationTapped(7)) { $0.isLoading = true }
        await store.receive(\.challengeChanged)
        await store.finish()

        let requests = await repository.changeRequests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first?.groupId, 12)
        XCTAssertEqual(requests.first?.challengeId, 7)
        XCTAssertFalse(store.state.isLoading)
        XCTAssertEqual(outputs, [.stepChallengeChanged])
        XCTAssertEqual(routes, [.back])
    }

    func testChangeFailureShowsErrorWithoutRouting() async {
        let repository = ChallengeFeatureRepositorySpy()
        await repository.setChangeError(.networkUnavailable)
        var outputs: [ChallengeOutput] = []
        var routes: [ChallengeChangeRoute] = []
        var state = ChallengeChangeFeature.State(groupId: 12)
        state.changableChallengeList = [option(id: 7)]
        let store = makeStore(
            state: state, repository: repository,
            router: { routes.append($0) }, output: { outputs.append($0) }
        )
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.challengeChangeConfirmationTapped(7)) { $0.isLoading = true }
        await store.receive(\.showAlert, .error(.networkUnavailable)) {
            $0.isLoading = false
            $0.alertCase = .error(.networkUnavailable)
        }
        await store.finish()

        XCTAssertTrue(outputs.isEmpty)
        XCTAssertTrue(routes.isEmpty)
        let requests = await repository.changeRequests
        XCTAssertEqual(requests.count, 1)
    }

    func testUnknownChallengeIdDoesNotCallChangeAPI() async {
        let repository = ChallengeFeatureRepositorySpy()
        var state = ChallengeChangeFeature.State(groupId: 12)
        state.changableChallengeList = [option(id: 7)]
        let store = makeStore(state: state, repository: repository)
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.challengeChangeConfirmationTapped(999))
        await store.receive(\.alertAction)
        await store.finish()

        XCTAssertFalse(store.state.isLoading)
        let requests = await repository.changeRequests
        XCTAssertTrue(requests.isEmpty)
    }

    private func option(
        id: Int,
        selected: Bool = false,
        completed: Bool = false
    ) -> ChangableWalkChallengeModel {
        ChangableWalkChallengeModel(
            challengeId: id, walkChallengeGroup: .seoulIncheon,
            departure: .seoul, destination: .incheon,
            distanceKm: 41.2, targetStepCount: 100_000,
            selected: selected, completed: completed
        )
    }

    private func makeStore(
        state: ChallengeChangeFeature.State = .init(groupId: 12),
        repository: ChallengeFeatureRepositorySpy,
        router: @escaping @MainActor (ChallengeChangeRoute) -> Void = { _ in },
        output: @escaping @MainActor (ChallengeOutput) -> Void = { _ in }
    ) -> TestStoreOf<ChallengeChangeFeature> {
        TestStore(initialState: state) {
            ChallengeChangeFeature(
                challengeUseCase: ChallengeUseCase(repository: repository),
                router: router,
                output: output
            )
        }
    }
}
