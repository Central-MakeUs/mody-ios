//
//  GroupParticipateFeatureTests.swift
//  ModyGroupTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import ComposableArchitecture
import ModyGroupInterface
import XCTest
@testable import ModyGroup

@MainActor
final class GroupParticipateFeatureTests: XCTestCase {
    func testJoinRequiresEightCharacterCode() async {
        let useCase = GroupUseCaseSpy()
        var state = GroupParticipateFeature.State(
            showSignUpDoneContents: false, showsBackButton: false
        )
        state.inviteCode = "SHORT"
        let store = makeStore(state: state, useCase: useCase)

        await store.send(.participateButtonTapped)

        XCTAssertTrue(useCase.joinedCodes.isEmpty)
        XCTAssertFalse(store.state.isLoading)
    }

    func testJoinSuccessCallsUseCaseAndStopsLoading() async {
        let useCase = GroupUseCaseSpy()
        var state = GroupParticipateFeature.State(
            showSignUpDoneContents: false, showsBackButton: false
        )
        state.inviteCode = "ABCD1234"
        let store = makeStore(state: state, useCase: useCase)

        await store.send(.participateButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.joinGroupSuccessfully) {
            $0.isLoading = false
        }

        XCTAssertEqual(useCase.joinedCodes, ["ABCD1234"])
    }

    func testKnownJoinErrorsAreInlineAndCodeChangeClearsError() async {
        let cases: [(code: String, expected: GroupParticipateFeature.State.JoinError)] = [
            (ServerErrorCode.group301.code, .notFound),
            (ServerErrorCode.group304.code, .groupLimitExceeded)
        ]

        for testCase in cases {
            var state = GroupParticipateFeature.State(
                showSignUpDoneContents: false, showsBackButton: false
            )
            state.inviteCode = "ABCD1234"
            state.isLoading = true
            let store = makeStore(state: state)
            let error = NetworkError.serverError(
                code: testCase.code, message: nil, fallback: .badRequest
            )

            await store.send(.joinGroupFailure(error, code: "ABCD1234")) {
                $0.isLoading = false
                $0.joinError = testCase.expected
            }
            await store.send(.binding(.set(\.inviteCode, "NEXT1234"))) {
                $0.inviteCode = "NEXT1234"
                $0.joinError = nil
            }
        }
    }

    func testOtherJoinErrorsShowFallbackAlert() async {
        var state = GroupParticipateFeature.State(
            showSignUpDoneContents: false, showsBackButton: false
        )
        state.inviteCode = "ABCD1234"
        let store = makeStore(state: state)
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.joinGroupFailure(
            .serverError(code: "GROUP999", message: nil, fallback: .serverUnavailable),
            code: "ABCD1234"
        ))
        await store.receive(\.showAlert, .error(.serverUnavailable)) {
            $0.isLoading = false
            $0.alertCase = .error(.serverUnavailable)
        }

        XCTAssertNil(store.state.joinError)
    }

    func testStaleJoinFailureDoesNotShowError() async {
        var state = GroupParticipateFeature.State(
            showSignUpDoneContents: false, showsBackButton: false
        )
        state.inviteCode = "NEWCODE1"
        state.isLoading = true
        let store = makeStore(state: state)

        await store.send(.joinGroupFailure(.networkUnavailable, code: "OLDCODE1")) {
            $0.isLoading = false
        }

        XCTAssertNil(store.state.alertCase)
        XCTAssertNil(store.state.joinError)
    }

    func testUnexpectedJoinFailureShowsUnknownAlert() async {
        let useCase = GroupUseCaseSpy()
        useCase.joinResult = .failure(UnexpectedJoinError())
        var state = GroupParticipateFeature.State(
            showSignUpDoneContents: false, showsBackButton: false
        )
        state.inviteCode = "ABCD1234"
        let store = makeStore(state: state, useCase: useCase)
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.participateButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.joinGroupFailure) {
            $0.isLoading = false
        }
        await store.receive(\.showAlert, .error(.unknown)) {
            $0.alertCase = .error(.unknown)
        }

        XCTAssertEqual(useCase.joinedCodes, ["ABCD1234"])
    }

    private func makeStore(
        state: GroupParticipateFeature.State = .init(
            showSignUpDoneContents: false, showsBackButton: false
        ),
        useCase: GroupUseCaseSpy = GroupUseCaseSpy()
    ) -> TestStoreOf<GroupParticipateFeature> {
        TestStore(initialState: state) {
            GroupParticipateFeature(groupUseCase: useCase)
        }
    }
}

private struct UnexpectedJoinError: Error {}
