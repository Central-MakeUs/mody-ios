//
//  FeedRecordReactor.swift
//  Feed
//
//  Created by 김동준 on 7/12/26.
//

import Foundation
import CommonDomain
import CoreCameraInterface
import FeedInterface
import ReactorKit
import UIKit

public final class FeedRecordReactor: Reactor {
    public let initialState: State
    private weak var router: FeedRecordRouter?
    private let feedUseCase: FeedUseCase
    private let output: @MainActor (FeedRecordOutput) -> Void

    public enum PhotoPresentation: Equatable {
        case none
        case sourceSheet
        case capture(CameraCaptureSource)
    }

    public struct State {
        let recordType: FeedRecordType
        var mealMenu = ""
        var mealTime: Date
        var selectedExerciseType: FeedExerciseType?
        var customExerciseName = ""
        var exerciseHours = 2
        var exerciseMinutes = 0
        var isExerciseMenuExpanded = false
        var photoPresentation = PhotoPresentation.none
        var selectedPhoto: CameraCaptureResult?
        var isSubmittingRecord = false
        var recordFailureAlert: NetworkError?

        var isFinishButtonEnabled: Bool {
            guard selectedPhoto != nil,
                  !isSubmittingRecord else {
                return false
            }

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
        case didDismissPhotoPresentation
        case didTapCamera
        case didTapGallery
        case didCompletePhotoCapture(CameraCaptureResult)
        case didChangeMealMenu(String)
        case didChangeMealTime(Date)
        case didTapExerciseMenu
        case didSelectExerciseType(FeedExerciseType)
        case didChangeCustomExerciseName(String)
        case didChangeExerciseDuration(hours: Int, minutes: Int)
        case didTapFinishButton
        case didDismissRecordFailureAlert
    }

    public enum Mutation {
        case setPhotoPresentation(PhotoPresentation)
        case completePhotoCapture(CameraCaptureResult)
        case setMealMenu(String)
        case setMealTime(Date)
        case setExerciseMenuExpanded(Bool)
        case setExerciseType(FeedExerciseType)
        case setCustomExerciseName(String)
        case setExerciseDuration(hours: Int, minutes: Int)
        case setSubmittingRecord(Bool)
        case setRecordFailureAlert(NetworkError?)
    }

    public init(
        router: FeedRecordRouter,
        recordType: FeedRecordType,
        feedUseCase: FeedUseCase,
        outputHandler: FeedRecordOutputHandler
    ) {
        self.router = router
        self.feedUseCase = feedUseCase
        self.output = { [weak outputHandler] output in
            outputHandler?.handle(output: output)
        }
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
            return .just(.setPhotoPresentation(.sourceSheet))
        case .didDismissPhotoPresentation:
            return .just(.setPhotoPresentation(.none))
        case .didTapCamera:
            return .just(.setPhotoPresentation(.capture(.camera)))
        case .didTapGallery:
            return .just(.setPhotoPresentation(.capture(.photoLibrary)))
        case let .didCompletePhotoCapture(result):
            return .just(.completePhotoCapture(result))
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
            return submitRecord(currentState)
        case .didDismissRecordFailureAlert:
            return .just(.setRecordFailureAlert(nil))
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setPhotoPresentation(presentation):
            newState.photoPresentation = presentation
        case let .completePhotoCapture(result):
            newState.photoPresentation = .none
            newState.selectedPhoto = result
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
        case let .setSubmittingRecord(isSubmitting):
            newState.isSubmittingRecord = isSubmitting
        case let .setRecordFailureAlert(error):
            newState.recordFailureAlert = error
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

    func submitRecord(_ state: State) -> Observable<Mutation> {
        guard let request = Self.makeRecordCreateRequest(from: state) else {
            return .just(.setRecordFailureAlert(.invalidResponse))
        }

        return Observable<Mutation>.create { [weak self] observer in
            let task = Task {
                guard let self else { return }
                await MainActor.run {
                    observer.onNext(.setSubmittingRecord(true))
                }

                do {
                    try await self.feedUseCase.createRecord(request)
                    await self.output(.recordCreated)
                    await MainActor.run {
                        observer.onCompleted()
                    }
                } catch let networkError as NetworkError {
                    await MainActor.run {
                        observer.onNext(.setSubmittingRecord(false))
                        observer.onNext(.setRecordFailureAlert(networkError))
                        observer.onCompleted()
                    }
                } catch {
                    await MainActor.run {
                        observer.onNext(.setSubmittingRecord(false))
                        observer.onNext(.setRecordFailureAlert(.unknown))
                        observer.onCompleted()
                    }
                }
            }

            return Disposables.create { task.cancel() }
        }
    }
}

private extension FeedRecordReactor {
    static func makeRecordCreateRequest(from state: State) -> FeedRecordCreateRequest? {
        guard let selectedPhoto = state.selectedPhoto,
              let uploadImage = makeUploadImage(from: selectedPhoto) else {
            return nil
        }

        let normalizedFrame = selectedPhoto.normalizedSelectionFrame
        guard normalizedFrame.width > 0,
              normalizedFrame.height > 0 else {
            return nil
        }

        let cropRegion = FeedRecordImageCropRegionRequest(
            x: Double(normalizedFrame.origin.x).clamped(to: 0...1),
            y: Double(normalizedFrame.origin.y).clamped(to: 0...1),
            width: Double(normalizedFrame.width).clamped(to: 0...1),
            height: Double(normalizedFrame.height).clamped(to: 0...1)
        )

        switch state.recordType {
        case .meal:
            let calendar = koreanCalendar()
            let hour = calendar.component(.hour, from: state.mealTime)
            let minute = calendar.component(.minute, from: state.mealTime)
            return FeedRecordCreateRequest(
                recordType: .meal,
                imageData: uploadImage.data,
                imageFileName: uploadImage.fileName,
                mealTime: String(format: "%02d:%02d", hour, minute),
                menu: state.mealMenu.trimmingCharacters(in: .whitespacesAndNewlines),
                imageCropRegion: cropRegion
            )
        case .exercise:
            guard let selectedExerciseType = state.selectedExerciseType else {
                return nil
            }

            let exerciseName = selectedExerciseType == .custom
                ? state.customExerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
                : selectedExerciseType.name

            return FeedRecordCreateRequest(
                recordType: .exercise,
                imageData: uploadImage.data,
                imageFileName: uploadImage.fileName,
                exerciseDurationHours: state.exerciseHours,
                exerciseDurationMinutes: state.exerciseMinutes,
                exerciseName: exerciseName,
                imageCropRegion: cropRegion
            )
        }
    }

    static func makeUploadImage(from result: CameraCaptureResult) -> (data: Data, fileName: String)? {
        let fileName = result.originalFileName.trimmingCharacters(in: .whitespacesAndNewlines)

        if fileName.lowercased().hasSuffix(".png"),
           let data = result.image.pngData() {
            return (data, fileName)
        }

        guard let data = result.image.jpegData(compressionQuality: 0.9) else {
            return nil
        }

        return (data, normalizedJPEGFileName(fileName))
    }

    static func normalizedJPEGFileName(_ fileName: String) -> String {
        guard !fileName.isEmpty else {
            return "record.jpg"
        }

        let lowercasedFileName = fileName.lowercased()
        if lowercasedFileName.hasSuffix(".jpg") || lowercasedFileName.hasSuffix(".jpeg") {
            return fileName
        }

        let url = URL(fileURLWithPath: fileName)
        let baseName = url.deletingPathExtension().lastPathComponent

        return "\(baseName.isEmpty ? "record" : baseName).jpg"
    }

    static func koreanCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        return calendar
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
