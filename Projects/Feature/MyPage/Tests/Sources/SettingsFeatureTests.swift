//
//  SettingsFeatureTests.swift
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
final class SettingsFeatureTests: XCTestCase {
    func testGroupFetchSuccessAndFailure() async {
        for fails in [false, true] {
            let groups = MyPageGroupSpy()
            groups.groups = [.init(groupId: 1, name: "그룹", code: "ABC", memberCount: 3)]
            groups.error = fails ? NetworkError.networkUnavailable : nil
            let store = TestStore(initialState: GroupSettingsFeature.State()) {
                GroupSettingsFeature(groupUseCase: groups, router: { _ in }, output: { _ in })
            }
            store.exhaustivity = .off(showSkippedAssertions: false)
            await store.send(.onAppear)
            XCTAssertTrue(store.state.isLoading)
            if fails {
                await store.receive(\.groupsFetchFailed, .networkUnavailable)
            } else {
                await store.receive(\.groupsFetched, groups.groups)
            }
            await store.finish()
            await store.skipReceivedActions(strict: false)
            XCTAssertFalse(store.state.isLoading)
            XCTAssertEqual(store.state.groups, fails ? [] : groups.groups)
            XCTAssertEqual(store.state.alertCase, fails ? .error(.networkUnavailable) : nil)
            XCTAssertEqual(groups.fetchCount, 1)
        }
    }

    func testExitingGroupOnlyRoutesWhenLastGroupRemoved() async {
        for lastGroup in [true, false] {
            let groups = MyPageGroupSpy()
            let first = GroupModel(groupId: 1, name: "첫 그룹", code: "ABC", memberCount: 3)
            let second = GroupModel(groupId: 2, name: "둘째", code: "DEF", memberCount: 2)
            var state = GroupSettingsFeature.State()
            state.groups = lastGroup ? [first] : [first, second]
            var routes: [MyPageGroupSettingsRoute] = []
            var outputs: [MyPageOutput] = []
            let store = TestStore(initialState: state) {
                GroupSettingsFeature(groupUseCase: groups, router: { routes.append($0) }, output: { outputs.append($0) })
            }
            store.exhaustivity = .off(showSkippedAssertions: false)
            await store.send(.exitButtonTapped(groupID: 1))
            await store.finish()
            await store.skipReceivedActions(strict: false)
            XCTAssertEqual(store.state.alertCase, .exitConfirmation(groupID: 1))
            XCTAssertTrue(groups.exitedIDs.isEmpty)
            await store.send(.exitConfirmationTapped)
            await store.receive(\.groupExited)
            await store.finish()
            await store.skipReceivedActions(strict: false)
            XCTAssertEqual(store.state.groups, lastGroup ? [] : [second])
            XCTAssertFalse(store.state.isLoading)
            XCTAssertEqual(groups.exitedIDs, [1])
            XCTAssertEqual(outputs, [.groupUpdated])
            XCTAssertEqual(routes, lastGroup ? [.routeToGroupParticipate] : [])
        }
    }

    func testExitFailurePreservesGroupsWithoutOutputOrRoute() async {
        let groups = MyPageGroupSpy()
        groups.error = NetworkError.networkUnavailable
        var state = GroupSettingsFeature.State()
        state.groups = [.init(groupId: 7, name: "그룹", code: "ABC", memberCount: 3)]
        state.alertCase = .exitConfirmation(groupID: 7)
        var routes: [MyPageGroupSettingsRoute] = []
        var outputs: [MyPageOutput] = []
        let store = TestStore(initialState: state) {
            GroupSettingsFeature(groupUseCase: groups, router: { routes.append($0) }, output: { outputs.append($0) })
        }
        store.exhaustivity = .off(showSkippedAssertions: false)
        await store.send(.exitConfirmationTapped)
        await store.receive(\.groupExitFailed, .networkUnavailable)
        await store.finish()
        await store.skipReceivedActions(strict: false)
        XCTAssertEqual(store.state.groups, state.groups)
        XCTAssertEqual(store.state.alertCase, .error(.networkUnavailable))
        XCTAssertFalse(store.state.isLoading)
        XCTAssertEqual(groups.exitedIDs, [7])
        XCTAssertTrue(routes.isEmpty)
        XCTAssertTrue(outputs.isEmpty)
    }

    func testExitWithoutConfirmationDoesNothingAndBackRoutes() async {
        let groups = MyPageGroupSpy()
        var routes: [MyPageGroupSettingsRoute] = []
        let store = TestStore(initialState: GroupSettingsFeature.State()) {
            GroupSettingsFeature(groupUseCase: groups, router: { routes.append($0) }, output: { _ in })
        }
        await store.send(.exitConfirmationTapped)
        XCTAssertTrue(groups.exitedIDs.isEmpty)
        await store.send(.backButtonTapped).finish()
        XCTAssertEqual(routes, [.back])
    }

    func testHealthPermissionOnlyRequestsWhenNeededAndBackRoutes() async {
        for shouldRequest in [false, true] {
            let permission = MyPageHealthPermissionSpy()
            permission.shouldRequest = shouldRequest
            var routes: [MyPageHealthDataSettingsRoute] = []
            let store = TestStore(initialState: HealthDataSettingsFeature.State()) {
                HealthDataSettingsFeature(healthPermissionInterface: permission, router: { routes.append($0) })
            }
            await store.send(.onAppear).finish()
            XCTAssertEqual(permission.checkCount, 1)
            XCTAssertEqual(permission.requestCount, shouldRequest ? 1 : 0)
            await store.send(.backButtonTapped).finish()
            XCTAssertEqual(routes, [.back])
        }
    }
}
