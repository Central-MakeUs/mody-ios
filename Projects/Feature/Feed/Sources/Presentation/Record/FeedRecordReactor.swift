//
//  FeedRecordReactor.swift
//  Feed
//
//  Created by 김동준 on 7/12/26.
//

import Foundation
import FeedInterface
import ReactorKit

public final class FeedRecordReactor: Reactor {
    public let initialState: State
    private weak var router: FeedRecordRouter?

    public struct State {
        let recordType: FeedRecordType
        var mealMenu = ""
        var mealTime: Date
        var selectedExerciseType: FeedExerciseType?
        var customExerciseName = ""
        var exerciseHours = 2
        var exerciseMinutes = 0
        var isExerciseMenuExpanded = false
        var isPhotoSourceSheetPresented = false

        var isFinishButtonEnabled: Bool {
            switch recordType {
            case .meal:
                return !mealMenu.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            case .exercise:
                guard let selectedExerciseType else { return false }
                let hasValidExercise = selectedExerciseType != .custom
                    || !customExerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                let hasValidDuration = exerciseHours > 0 || exerciseMinutes > 0
                return hasValidExercise && hasValidDuration
            }
        }
    }

    public enum Action {
        case didTapBackButton
        case didTapPhotoUpload
        case didDismissPhotoSourceSheet
        case didTapCamera
        case didTapGallery
        case didChangeMealMenu(String)
        case didChangeMealTime(Date)
        case didTapExerciseMenu
        case didSelectExerciseType(FeedExerciseType)
        case didChangeCustomExerciseName(String)
        case didChangeExerciseDuration(hours: Int, minutes: Int)
        case didTapFinishButton
    }

    public enum Mutation {
        case setPhotoSourceSheetPresented(Bool)
        case setMealMenu(String)
        case setMealTime(Date)
        case setExerciseMenuExpanded(Bool)
        case setExerciseType(FeedExerciseType)
        case setCustomExerciseName(String)
        case setExerciseDuration(hours: Int, minutes: Int)
    }

    public init(
        router: FeedRecordRouter,
        recordType: FeedRecordType
    ) {
        self.router = router
        self.initialState = State(
            recordType: recordType,
            mealTime: Self.makeInitialMealTime()
        )
    }

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapBackButton:
            return routeToBack()
        case .didTapPhotoUpload:
            print("[FeedRecordReactor] 사진 업로드하기")
            return .just(.setPhotoSourceSheetPresented(true))
        case .didDismissPhotoSourceSheet:
            return .just(.setPhotoSourceSheetPresented(false))
        case .didTapCamera:
            print("[FeedRecordReactor] 사진 촬영하기")
            return .just(.setPhotoSourceSheetPresented(false))
        case .didTapGallery:
            print("[FeedRecordReactor] 갤러리에서 선택하기")
            return .just(.setPhotoSourceSheetPresented(false))
        case let .didChangeMealMenu(menu):
            return .just(.setMealMenu(menu))
        case let .didChangeMealTime(date):
            return .just(.setMealTime(date))
        case .didTapExerciseMenu:
            return .just(.setExerciseMenuExpanded(!currentState.isExerciseMenuExpanded))
        case let .didSelectExerciseType(type):
            return .just(.setExerciseType(type))
        case let .didChangeCustomExerciseName(name):
            return .just(.setCustomExerciseName(name))
        case let .didChangeExerciseDuration(hours, minutes):
            return .just(.setExerciseDuration(hours: hours, minutes: minutes))
        case .didTapFinishButton:
            guard currentState.isFinishButtonEnabled else { return .empty() }
            print("[FeedRecordReactor] 작성 완료")
            return .empty()
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setPhotoSourceSheetPresented(isPresented):
            newState.isPhotoSourceSheetPresented = isPresented
        case let .setMealMenu(menu):
            newState.mealMenu = menu
        case let .setMealTime(date):
            newState.mealTime = date
        case let .setExerciseMenuExpanded(isExpanded):
            newState.isExerciseMenuExpanded = isExpanded
        case let .setExerciseType(type):
            newState.selectedExerciseType = type
            newState.isExerciseMenuExpanded = false
        case let .setCustomExerciseName(name):
            newState.customExerciseName = name
        case let .setExerciseDuration(hours, minutes):
            newState.exerciseHours = hours
            newState.exerciseMinutes = minutes
        }

        return newState
    }
}

private extension FeedRecordReactor {
    static func makeInitialMealTime() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        return calendar.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: Date()
        ) ?? Date()
    }

    func routeToBack() -> Observable<Mutation> {
        return .deferred { [weak router] in
            Task { @MainActor in
                router?.route(from: .back)
            }
            return .empty()
        }
    }
}
