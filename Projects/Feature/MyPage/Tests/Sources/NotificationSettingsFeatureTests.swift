//
//  NotificationSettingsFeatureTests.swift
//  MyPageTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import ComposableArchitecture
import MyPageInterface
import Util
import XCTest
@testable import MyPage

@MainActor
final class NotificationSettingsFeatureTests: XCTestCase {
    func testPermissionDeniedDoesNotRequestAgain() async {
        let permission = MyPageNotificationPermissionSpy()
        let store = makeStore(permission: permission)
        await store.send(.checkNotificationPermission)
        await store.receive(\.setNotificationPermissionGranted, false)
        await store.finish()
        XCTAssertFalse(store.state.isNotificationPermissionGranted)
        XCTAssertEqual(permission.requestCount, 0)
        XCTAssertEqual(permission.grantedCheckCount, 1)
    }

    func testUndeterminedPermissionRequestsAndUsesResult() async {
        for granted in [true, false] {
            let permission = MyPageNotificationPermissionSpy()
            permission.notDetermined = true
            permission.granted = granted
            let store = makeStore(permission: permission)
            await store.send(.checkNotificationPermission)
            if granted {
                await store.receive(\.setNotificationPermissionGranted, true) {
                    $0.isNotificationPermissionGranted = true
                }
            } else {
                await store.receive(\.setNotificationPermissionGranted, false)
            }
            XCTAssertEqual(permission.requestCount, 1)
            XCTAssertEqual(permission.grantedCheckCount, 0)
        }
    }

    func testPermissionRecheckReflectsSettingsChange() async {
        let permission = MyPageNotificationPermissionSpy()
        var state = NotificationSettingsFeature.State()
        state.isNotificationPermissionGranted = true
        let store = makeStore(state: state, permission: permission)
        await store.send(.checkNotificationPermission)
        await store.receive(\.setNotificationPermissionGranted, false) {
            $0.isNotificationPermissionGranted = false
        }
    }

    func testOnAppearFetchesSettingsAndPermission() async {
        let repository = MyPageNotificationRepositorySpy()
        let store = makeStore(repository: repository)
        store.exhaustivity = .off(showSkippedAssertions: false)
        await store.send(.onAppear)
        XCTAssertTrue(store.state.isLoading)
        await store.receive(\.notificationSettingsFetched)
        await store.finish()
        await store.skipReceivedActions(strict: false)
        XCTAssertEqual(store.state.notificationSetting, MyPageFixture.settings)
        XCTAssertFalse(store.state.isLoading)
        XCTAssertFalse(store.state.isNotificationPermissionGranted)
        XCTAssertEqual(repository.fetchCount, 1)
    }

    func testFetchFailureClearsLoadingAndPresentsError() async {
        let repository = MyPageNotificationRepositorySpy()
        repository.fetchResult = .failure(NetworkError.networkUnavailable)
        let store = makeStore(repository: repository)
        store.exhaustivity = .off(showSkippedAssertions: false)
        await store.send(.onAppear)
        await store.receive(\.notificationSettingsFetchFailed, .networkUnavailable)
        await store.receive(\.showAlert, .error(.networkUnavailable))
        await store.finish()
        await store.skipReceivedActions(strict: false)
        XCTAssertFalse(store.state.isLoading)
        XCTAssertEqual(store.state.alertCase, .error(.networkUnavailable))
        XCTAssertTrue(store.state.alertState.isPresented)
    }

    func testEachToggleWaitsForResponseThenAppliesUpdatedSettings() async {
        let types: [NotificationSettingsFeature.State.NotificationSettingType] = [.comment, .challenge, .mealAndExercise]
        for type in types {
            let repository = MyPageNotificationRepositorySpy()
            var state = NotificationSettingsFeature.State()
            state.notificationSetting = MyPageFixture.settings
            var expected = state.notificationSetting
            switch type {
            case .comment: expected.commentNotificationEnabled = false
            case .challenge: expected.challengeNotificationEnabled = true
            case .mealAndExercise: expected.mealAndExerciseEnabled = false
            }
            let store = makeStore(state: state, repository: repository)
            await store.send(.notificationToggleChanged(type, isOn: type == .challenge)) {
                $0.isLoading = true
            }
            XCTAssertEqual(store.state.notificationSetting, state.notificationSetting)
            await store.receive(\.notificationSettingsUpdated, expected) {
                $0.isLoading = false
                $0.notificationSetting = expected
            }
            XCTAssertEqual(repository.updates, [expected])
        }
    }

    func testToggleFailureRetainsSettingsAndStopsLoading() async {
        let repository = MyPageNotificationRepositorySpy()
        repository.updateError = NetworkError.networkUnavailable
        var state = NotificationSettingsFeature.State()
        state.notificationSetting = MyPageFixture.settings
        let store = makeStore(state: state, repository: repository)
        store.exhaustivity = .off(showSkippedAssertions: false)
        await store.send(.notificationToggleChanged(.comment, isOn: false))
        XCTAssertTrue(store.state.isLoading)
        await store.receive(\.notificationSettingsUpdateFailed, .networkUnavailable)
        await store.receive(\.showAlert, .error(.networkUnavailable))
        await store.finish()
        await store.skipReceivedActions(strict: false)
        XCTAssertEqual(store.state.notificationSetting, state.notificationSetting)
        XCTAssertFalse(store.state.isLoading)
        XCTAssertTrue(store.state.alertState.isPresented)
        XCTAssertEqual(repository.updates.count, 1)
    }

    func testSaveSchedulesSuccessAndFailure() async {
        for fails in [false, true] {
            let repository = MyPageNotificationRepositorySpy()
            repository.updateError = fails ? NetworkError.networkUnavailable : nil
            var state = NotificationSettingsFeature.State()
            state.notificationSetting = MyPageFixture.settings
            let store = makeStore(state: state, repository: repository)
            store.exhaustivity = .off(showSkippedAssertions: false)
            await store.send(.saveButtonTapped)
            XCTAssertTrue(store.state.isLoading)
            if fails {
                await store.receive(\.schedulesUpdateFailed, .networkUnavailable)
            } else {
                await store.receive(\.schedulesUpdated)
            }
            await store.receive(\.showAlert)
            await store.finish()
            await store.skipReceivedActions(strict: false)
            XCTAssertEqual(store.state.alertCase, fails ? .error(.networkUnavailable) : .success)
            XCTAssertFalse(store.state.isLoading)
            XCTAssertTrue(store.state.alertState.isPresented)
            XCTAssertEqual(repository.schedules.count, 1)
            XCTAssertEqual(repository.schedules.first?.meals, state.notificationSetting.mealSchedules)
            XCTAssertEqual(repository.schedules.first?.exercises, state.notificationSetting.exerciseSchedules)
        }
    }

    func testInvalidOrLoadingSchedulesDoNotSave() async {
        for condition in 0..<4 {
            let repository = MyPageNotificationRepositorySpy()
            var state = NotificationSettingsFeature.State()
            state.notificationSetting = MyPageFixture.settings
            switch condition {
            case 0: state.notificationSetting.mealAndExerciseEnabled = false
            case 1: state.notificationSetting.exerciseSchedules = []
            case 2:
                state.notificationSetting.mealSchedules = MealType.allCases.map {
                    MealScheduleRequest(mealType: $0, time: nil, skipped: true)
                }
            default: state.isLoading = true
            }
            let store = makeStore(state: state, repository: repository)
            await store.send(.saveButtonTapped)
            XCTAssertTrue(repository.schedules.isEmpty)
        }
    }

    func testMealAndWeekdayEditsRemainLocal() async {
        let repository = MyPageNotificationRepositorySpy()
        var state = NotificationSettingsFeature.State()
        state.notificationSetting = MyPageFixture.settings
        let store = makeStore(state: state, repository: repository)
        store.exhaustivity = .off(showSkippedAssertions: false)
        await store.send(.mealSkipTapped(.breakfast))
        XCTAssertEqual(store.state.skippedMeals, [.breakfast])
        XCTAssertNil(store.state.notificationSetting.mealSchedules.first { $0.mealType == .breakfast }?.time)
        await store.send(.mealDropdownTapped(.breakfast))
        XCTAssertNil(store.state.expandedMeal)
        await store.send(.mealSkipTapped(.breakfast))
        await store.send(.mealHourTapped(meal: .breakfast, hour: 10))
        XCTAssertEqual(store.state.notificationSetting.mealSchedules.first { $0.mealType == .breakfast }?.time, "10:00")
        await store.send(.weekdayTapped(.monday))
        XCTAssertTrue(store.state.selectedWeekdays.isEmpty)
        await store.send(.weekdayTapped(.friday))
        XCTAssertEqual(store.state.notificationSetting.exerciseSchedules, [.init(dayOfWeek: .friday, time: "09:00")])
        XCTAssertTrue(repository.updates.isEmpty)
        XCTAssertTrue(repository.schedules.isEmpty)
    }

    func testExerciseTimeChangesApplyToOneDayOrAllSelectedDays() async {
        var state = NotificationSettingsFeature.State()
        state.notificationSetting = MyPageFixture.settings
        state.notificationSetting.exerciseSchedules.append(.init(dayOfWeek: .friday, time: "18:00"))
        let store = makeStore(state: state)
        store.exhaustivity = .off(showSkippedAssertions: false)
        await store.send(.exerciseScheduleTapped(.friday))
        XCTAssertTrue(store.state.isTimeSheetPresented)
        XCTAssertEqual(store.state.timeSheetTarget, .exerciseDay(.friday))
        let selectedDate = Date.fixedDateForHourMinTime(hour: 20, minute: 30, calendar: state.calendar)
        await store.send(.binding(.set(\.timeSheetDate, selectedDate)))
        await store.send(.timeSheetConfirmTapped)
        XCTAssertEqual(store.state.notificationSetting.exerciseSchedules, [
            .init(dayOfWeek: .monday, time: "09:00"), .init(dayOfWeek: .friday, time: "20:30")
        ])
        XCTAssertFalse(store.state.isTimeSheetPresented)
        XCTAssertNil(store.state.timeSheetTarget)
        await store.send(.sameExerciseTimeTapped)
        XCTAssertEqual(store.state.timeSheetTarget, .allExerciseDays)
        await store.send(.binding(.set(\.timeSheetDate, selectedDate)))
        await store.send(.timeSheetConfirmTapped)
        XCTAssertEqual(store.state.notificationSetting.exerciseSchedules, [
            .init(dayOfWeek: .monday, time: "20:30"), .init(dayOfWeek: .friday, time: "20:30")
        ])
    }

    func testBackRoutesOnce() async {
        var routes: [MyPageNotificationSettingsRoute] = []
        let store = TestStore(initialState: NotificationSettingsFeature.State()) {
            NotificationSettingsFeature(notificationPermission: MyPageNotificationPermissionSpy(),
                notificationSettingUseCase: .init(repository: MyPageNotificationRepositorySpy()), router: { routes.append($0) })
        }
        await store.send(.backButtonTapped).finish()
        XCTAssertEqual(routes, [.back])
    }

    private func makeStore(
        state: NotificationSettingsFeature.State = .init(),
        repository: MyPageNotificationRepositorySpy = .init(),
        permission: MyPageNotificationPermissionSpy = .init()
    ) -> TestStoreOf<NotificationSettingsFeature> {
        TestStore(initialState: state) {
            NotificationSettingsFeature(notificationPermission: permission,
                notificationSettingUseCase: .init(repository: repository), router: { _ in })
        }
    }
}
