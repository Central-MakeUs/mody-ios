//
//  FeedRecordReactor.swift
//  Feed
//
//  Created by 김동준 on 7/12/26.
//

import Foundation
import CommonDomain
import CoreCameraInterface
import CoreModyImageInterface
import FeedInterface
import ReactorKit

public final class FeedRecordReactor: Reactor {
    public let initialState: State
    private weak var router: FeedRecordRouter?
    private let feedUseCase: FeedUseCase
    private let imageUploadUseCase: ImageUploadUseCaseProtocol
    private let temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol
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
        imageUploadUseCase: ImageUploadUseCaseProtocol,
        temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol,
        outputHandler: FeedRecordOutputHandler
    ) {
        self.router = router
        self.feedUseCase = feedUseCase
        self.imageUploadUseCase = imageUploadUseCase
        self.temporaryImageFileUseCase = temporaryImageFileUseCase
        self.output = { [weak outputHandler] output in
            outputHandler?.handle(output: output)
        }
        self.initialState = State(
            recordType: recordType,
            mealTime: Self.makeInitialMealTime()
        )
    }

    deinit {
        removeSelectedPhotoFile()
    }

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapBackButton:
            guard !currentState.isSubmittingRecord else { return .empty() }
            removeSelectedPhotoFile()
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
            removeSelectedPhotoFile()
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
        guard let selectedPhoto = state.selectedPhoto else {
            return .just(.setRecordFailureAlert(.invalidResponse))
        }

        return Observable<Mutation>.create { [weak self] observer in
            let task = Task {
                guard let self else { return }
                await MainActor.run {
                    observer.onNext(.setSubmittingRecord(true))
                }

                do {
                    let imageKey = try await self.imageUploadUseCase.uploadImage(
                        fileURL: selectedPhoto.originalFile.fileURL,
                        fileName: selectedPhoto.originalFile.fileName,
                        domain: .record
                    )

                    guard let request = self.feedUseCase.makeRecordCreationRequest(
                        imageKey: imageKey,
                        recordType: state.recordType,
                        mealTime: state.mealTime,
                        mealMenu: state.mealMenu,
                        exerciseType: state.selectedExerciseType,
                        customExerciseName: state.customExerciseName,
                        exerciseDurationHours: state.exerciseHours,
                        exerciseDurationMinutes: state.exerciseMinutes,
                        normalizedImageCropRegion: selectedPhoto.normalizedSelectionFrame
                    ) else {
                        throw NetworkError.invalidResponse
                    }
                    try await self.feedUseCase.createRecord(request)
                    try? self.temporaryImageFileUseCase.removeImage(
                        at: selectedPhoto.originalFile.fileURL
                    )
                    await self.output(.recordCreated)
                    observer.onCompleted()
                } catch {
                    observer.onNext(.setSubmittingRecord(false))
                    observer.onNext(.setRecordFailureAlert(error as? NetworkError ?? .unknown))
                    observer.onCompleted()
                }
            }

            return Disposables.create { task.cancel() }
        }
        .observe(on: MainScheduler.instance)
    }

    func removeSelectedPhotoFile() {
        guard let fileURL = currentState.selectedPhoto?.originalFile.fileURL else { return }
        try? temporaryImageFileUseCase.removeImage(at: fileURL)
    }
}
