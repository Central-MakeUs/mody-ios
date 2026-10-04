//
//  GroupCreateFeatureTests.swift
//  ModyGroupTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import ComposableArchitecture
import XCTest
@testable import ModyGroup

@MainActor
final class GroupCreateFeatureTests: XCTestCase {
    func testNameValidationGuardsCreate() async {
        let useCase = GroupUseCaseSpy()
        let store = makeStore(useCase: useCase)

        await store.send(.nextButtonTapped)
        XCTAssertTrue(useCase.createdNames.isEmpty)

        await store.send(.binding(.set(\.groupName, "123456789012345"))) {
            $0.groupName = "123456789012345"
        }
        XCTAssertFalse(store.state.isNextButtonEnabled)
        XCTAssertNotNil(store.state.groupNameErrorMessage)
        await store.send(.nextButtonTapped)
        XCTAssertTrue(useCase.createdNames.isEmpty)
    }

    func testCreateUsesNameAndEmitsCodeAfterLoading() async {
        let useCase = GroupUseCaseSpy()
        var state = GroupCreateFeature.State()
        state.groupName = "우리 그룹"
        let store = makeStore(state: state, useCase: useCase)

        await store.send(.nextButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.createGroupSuccessfully, timeout: .seconds(4)) {
            $0.isLoading = false
        }
        await store.finish()

        XCTAssertEqual(useCase.createdNames, ["우리 그룹"])
        XCTAssertFalse(store.state.isLoading)
    }

    func testCreateFailureShowsNetworkErrorAndDismisses() async {
        let useCase = GroupUseCaseSpy()
        useCase.createResult = .failure(NetworkError.networkUnavailable)
        var state = GroupCreateFeature.State()
        state.groupName = "우리 그룹"
        let store = makeStore(state: state, useCase: useCase)
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.nextButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.showAlert, .error(.networkUnavailable), timeout: .seconds(4)) {
            $0.isLoading = false
            $0.alertCase = .error(.networkUnavailable)
        }
        await store.send(.alertAction(.dismiss)) {
            $0.alertCase = nil
        }

        XCTAssertEqual(useCase.createdNames, ["우리 그룹"])
    }

    private func makeStore(
        state: GroupCreateFeature.State = .init(),
        useCase: GroupUseCaseSpy = GroupUseCaseSpy()
    ) -> TestStoreOf<GroupCreateFeature> {
        TestStore(initialState: state) {
            GroupCreateFeature(groupUseCase: useCase)
        }
    }
}
