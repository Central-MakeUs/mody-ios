//
//  MyPageFeatureTests.swift
//  MyPageTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import ComposableArchitecture
import MyPageInterface
import XCTest
@testable import MyPage

@MainActor
final class MyPageFeatureTests: XCTestCase {
    func testInitialFetchRunsOnceAndProfileInputRefreshesOnlyUser() async {
        let auth = MyPageAuthSpy()
        let repository = MyPageRepositorySpy()
        let store = makeStore(auth: auth, repository: repository)
        store.exhaustivity = .off(showSkippedAssertions: false)
        await store.send(.onAppear)
        await store.receive(\.userInfoFetched)
        await store.finish()
        await store.skipReceivedActions(strict: false)
        XCTAssertEqual(store.state.userInfo, MyPageFixture.user)
        XCTAssertEqual(store.state.weightRecord, MyPageFixture.weight)
        await store.send(.onAppear)
        XCTAssertEqual(auth.userRequests, [false])
        XCTAssertEqual(repository.weightFetchCount, 1)
        await store.send(.input(.profileUpdated))
        XCTAssertTrue(store.state.isProfileRefreshing)
        await store.receive(\.userInfoFetched)
        await store.finish()
        await store.skipReceivedActions(strict: false)
        XCTAssertFalse(store.state.isProfileRefreshing)
        XCTAssertEqual(auth.userRequests, [false, false])
        XCTAssertEqual(repository.weightFetchCount, 1)
    }

    func testFetchFailuresLeaveExistingDataAndEndRefresh() async {
        let auth = MyPageAuthSpy()
        auth.userResult = .failure(NetworkError.networkUnavailable)
        let repository = MyPageRepositorySpy()
        repository.weightResult = .failure(NetworkError.networkUnavailable)
        let store = makeStore(auth: auth, repository: repository)
        store.exhaustivity = .off(showSkippedAssertions: false)
        await store.send(.onAppear)
        await store.receive(\.userInfoFetchFailed)
        await store.finish()
        await store.skipReceivedActions(strict: false)
        XCTAssertNil(store.state.userInfo)
        XCTAssertNil(store.state.weightRecord)
        await store.send(.input(.profileUpdated))
        await store.receive(\.userInfoFetchFailed)
        XCTAssertFalse(store.state.isProfileRefreshing)
    }

    func testRoutesAndMissingProfileGuard() async {
        var routes: [MyPageRoute] = []
        let store = makeStore(router: { routes.append($0) })
        await store.send(.profileEditButtonTapped)
        XCTAssertTrue(routes.isEmpty)
        await store.send(.userInfoFetched(MyPageFixture.user)) { $0.userInfo = MyPageFixture.user }
        await store.send(.profileEditButtonTapped).finish()
        await store.send(.notificationSettingsButtonTapped).finish()
        await store.send(.groupSettingsButtonTapped).finish()
        await store.send(.healthDataSettingsButtonTapped).finish()
        XCTAssertEqual(routes, [.routeToProfile(profileImageURL: nil, defaultAvatar: .poutBlack),
                                .routeToNotificationSettings, .routeToGroupSettings, .routeToHealthDataSettings])
    }

    func testWeightRecordingSuccessUpdatesWeightAndOutputsInOrder() async {
        let repository = MyPageRepositorySpy()
        var outputs: [MyPageOutput] = []
        var state = MyPageFeature.State(defaultAvatar: .poutBlack)
        state.weightRecord = MyPageFixture.weight
        state.weightRecordSheet = WeightRecordFeature.State(currentWeight: 70)
        state.weightRecordSheet?.dateText = "2026.10.05"
        let store = makeStore(state: state, repository: repository, output: { outputs.append($0) })
        await store.send(.weightRecordSheet(.presented(.recordButtonTapped))) {
            $0.isLoading = true
            $0.weightRecordSheet = nil
        }
        await store.receive(\.weightRecordSucceeded, 70) {
            $0.isLoading = false
            $0.weightRecord = WeightRecord(startWeightKg: 80, currentWeightKg: 70, targetWeightKg: 65)
        }
        await store.finish()
        XCTAssertEqual(repository.weightRequests.count, 1)
        XCTAssertEqual(repository.weightRequests.first?.recordedOn, "2026-10-05")
        XCTAssertEqual(repository.weightRequests.first?.weightKg, 70)
        XCTAssertEqual(outputs, [.weightRecordStarted, .weightRecordSucceeded])
    }

    func testWeightFailurePreservesWeightAndMapsUnknownError() async {
        for error in [NetworkError.networkUnavailable as Error, CancellationError()] {
            let repository = MyPageRepositorySpy()
            repository.updateResult = .failure(error)
            var outputs: [MyPageOutput] = []
            var state = MyPageFeature.State(defaultAvatar: .poutBlack)
            state.weightRecord = MyPageFixture.weight
            state.weightRecordSheet = WeightRecordFeature.State(currentWeight: 70)
            state.weightRecordSheet?.dateText = "2026.10.05"
            let store = makeStore(state: state, repository: repository, output: { outputs.append($0) })
            await store.send(.weightRecordSheet(.presented(.recordButtonTapped))) {
                $0.isLoading = true
                $0.weightRecordSheet = nil
            }
            let expected = error as? NetworkError ?? .unknown
            await store.receive(\.weightRecordFailed, expected) { $0.isLoading = false }
            await store.finish()
            XCTAssertEqual(store.state.weightRecord, MyPageFixture.weight)
            XCTAssertEqual(outputs, [.weightRecordStarted, .weightRecordFailed(expected)])
        }
    }

    func testInvalidDateAndLoadingPreventRecording() async {
        for loading in [true, false] {
            let repository = MyPageRepositorySpy()
            var state = MyPageFeature.State(defaultAvatar: .poutBlack)
            state.isLoading = loading
            state.weightRecordSheet = WeightRecordFeature.State(currentWeight: 70)
            state.weightRecordSheet?.dateText = loading ? "2026.10.05" : "2026.1.5"
            var outputs: [MyPageOutput] = []
            let store = makeStore(state: state, repository: repository, output: { outputs.append($0) })
            await store.send(.weightRecordSheet(.presented(.recordButtonTapped)))
            XCTAssertTrue(repository.weightRequests.isEmpty)
            XCTAssertTrue(outputs.isEmpty)
            XCTAssertNotNil(store.state.weightRecordSheet)
        }
    }

    func testWeightInputRoundsClampsAndValidatesDateFormat() {
        for (input, expected) in [(19.0, 20), (72.6, 73), (151.0, 150)] {
            XCTAssertEqual(WeightRecordFeature.State(currentWeight: input).currentWeightKg, expected)
        }
        var state = WeightRecordFeature.State(currentWeight: 70)
        for invalid in ["", "2026.1.05", "2026-10-05", "abcd.10.05", "2026.10."] {
            state.dateText = invalid
            XCTAssertTrue(state.isRecordButtonDisabled)
            XCTAssertNil(state.recordedOn)
        }
        state.dateText = "2026.10.05"
        XCTAssertFalse(state.isRecordButtonDisabled)
        XCTAssertEqual(state.recordedOn, "2026-10-05")
    }

    private func makeStore(
        state: MyPageFeature.State = .init(defaultAvatar: .poutBlack),
        auth: MyPageAuthSpy = .init(), repository: MyPageRepositorySpy = .init(),
        router: @escaping @MainActor (MyPageRoute) -> Void = { _ in },
        output: @escaping @MainActor (MyPageOutput) -> Void = { _ in }
    ) -> TestStoreOf<MyPageFeature> {
        TestStore(initialState: state) {
            MyPageFeature(authUseCase: auth, myPageUseCase: .init(myPageRepository: repository), router: router, output: output)
        }
    }
}
