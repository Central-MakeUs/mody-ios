//
//  ModyGroupRootFeatureTests.swift
//  ModyGroupTests
//
//  Created by 김동준 on 10/4/26.
//

import ComposableArchitecture
import ModyGroupInterface
import XCTest
@testable import ModyGroup

@MainActor
final class ModyGroupRootFeatureTests: XCTestCase {
    func testEntryPointControlsBackButtons() {
        let root = makeState(entryPoint: .root, initialScreen: .participate)
        let main = makeState(entryPoint: .main, initialScreen: .participate)
        let settings = makeState(
            entryPoint: .groupSettings, initialScreen: .create(needBackButton: false)
        )

        XCTAssertFalse(root.groupParticipateState.showsBackButton)
        XCTAssertTrue(main.groupParticipateState.showsBackButton)
        XCTAssertFalse(settings.groupCreateState.showsBackButton)
    }

    func testParticipateBackRoutesOutAndCreateOpensInternalPath() async {
        let navigation = ModyGroupEventSpy()
        let store = makeStore(navigation: navigation)
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.groupParticipateAction(.createButtonTapped))
        XCTAssertEqual(store.state.path.count, 1)

        await store.send(.groupParticipateAction(.backButtonTapped)).finish()
        XCTAssertEqual(navigation.routes, [.back])
    }

    func testJoinSuccessEmitsGroupUpdateThenFinish() async {
        let navigation = ModyGroupEventSpy()
        let store = makeStore(navigation: navigation)

        await store.send(.groupParticipateAction(.joinGroupSuccessfully)).finish()

        XCTAssertEqual(navigation.outputs, [.groupUpdated])
        XCTAssertEqual(navigation.routes, [.finish])
        XCTAssertEqual(navigation.events, ["output", "route"])
    }

    func testDirectCreateOpensInviteAndBackRoutesOut() async {
        let navigation = ModyGroupEventSpy()
        let store = makeStore(
            state: makeState(entryPoint: .main, initialScreen: .create(needBackButton: true)),
            navigation: navigation
        )
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.groupCreateAction(.createGroupSuccessfully(
            code: "ABCD1234", groupName: "우리 그룹"
        )))
        XCTAssertEqual(store.state.path.count, 1)

        await store.send(.groupCreateAction(.backButtonTapped)).finish()
        XCTAssertEqual(navigation.routes, [.back])
    }

    private func makeState(
        entryPoint: ModyGroupEntryPoint = .root,
        initialScreen: ModyGroupInitialScreen = .participate
    ) -> ModyGroupRootFeature.State {
        .init(
            entryPoint: entryPoint,
            showSignUpDoneContents: false,
            initialScreen: initialScreen
        )
    }

    private func makeStore(
        state: ModyGroupRootFeature.State? = nil,
        navigation: ModyGroupEventSpy? = nil
    ) -> TestStoreOf<ModyGroupRootFeature> {
        let navigation = navigation ?? ModyGroupEventSpy()
        let useCase = GroupUseCaseSpy()
        return TestStore(initialState: state ?? makeState()) {
            ModyGroupRootFeature(
                groupInviteFeature: GroupInviteFeature(
                    shareGroupInviteUseCase: ShareGroupInviteSpy()
                ),
                groupParticipateFeature: GroupParticipateFeature(groupUseCase: useCase),
                groupCreateFeature: GroupCreateFeature(groupUseCase: useCase),
                output: navigation.recordOutput,
                router: navigation.recordRoute
            )
        }
    }
}
