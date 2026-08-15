//
//  ChallengeWeeklyDetailFeature.swift
//  Challenge
//
//  Created by 김동준 on 8/12/26.
//

import Base
import ChallengeInterface
import CommonDomain
import ComposableArchitecture
import CoreAuthInterface
import CoreCameraInterface
import CoreModyImageInterface
import Foundation

@Reducer
public struct ChallengeWeeklyDetailFeature {
    private let authUseCase: AuthUseCaseProtocol
    private let challengeUseCase: ChallengeUseCase
    private let imageUploadUseCase: ImageUploadUseCaseProtocol
    private let temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol
    private let router: @MainActor (ChallengeWeeklyDetailRoute) -> Void
    private let output: @MainActor (ChallengeOutput) -> Void

    public init(
        authUseCase: AuthUseCaseProtocol,
        challengeUseCase: ChallengeUseCase,
        imageUploadUseCase: ImageUploadUseCaseProtocol,
        temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol,
        router: @escaping @MainActor (ChallengeWeeklyDetailRoute) -> Void,
        output: @escaping @MainActor (ChallengeOutput) -> Void
    ) {
        self.authUseCase = authUseCase
        self.challengeUseCase = challengeUseCase
        self.imageUploadUseCase = imageUploadUseCase
        self.temporaryImageFileUseCase = temporaryImageFileUseCase
        self.router = router
        self.output = output
    }

    @ObservableState
    public struct State: Equatable {
        public enum AlertCase: Equatable {
            case incompleteChallenge
            case error(NetworkError)
        }

        var isLoading = false
        var alertCase: AlertCase?
        var alertState = AlertFeature.State()
        var myMemberId: Int?
        var weeklyChallengeDetail: WeeklyChallengeDetail?
        var weeklyChallengeImageInfos: [WeeklyChallengeImageInfo]?
        var isPhotoSourceSheetPresented = false
        var isCameraPresented = false
        var photoCaptureSource: CameraCaptureSource?
        let groupId: Int
        let challengeId: Int
        let groupChallengeId: Int

        var showsAuthenticationItem: Bool {
            guard let myMemberId,
                  let weeklyChallengeImageInfos else {
                return false
            }

            return !weeklyChallengeImageInfos.contains {
                $0.memberId == myMemberId
            }
        }

        var isShareButtonDisabled: Bool {
            isLoading || weeklyChallengeImageInfos?.isEmpty != false
        }

        public init(groupId: Int, challengeId: Int, groupChallengeId: Int) {
            self.groupId = groupId
            self.challengeId = challengeId
            self.groupChallengeId = groupChallengeId
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case alertAction(AlertFeature.Action)
        case showAlert(State.AlertCase)
        case backButtonTapped
        case onAppear
        case authenticationButtonTapped
        case cameraSourceTapped
        case gallerySourceTapped
        case photoCaptureCompleted(CameraCaptureResult)
        case photoCaptureCancelled
        case weeklyChallengeProofCreated([WeeklyChallengeImageInfo])
        case snsShareButtonTapped
        case weeklyChallengeShareFinished(String)
        case initialDataFetched(
            memberId: Int,
            detail: WeeklyChallengeDetail,
            imageInfos: [WeeklyChallengeImageInfo]
        )
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.alertState, action: \.alertAction) {
            AlertFeature()
        }

        Reduce { state, action in
            switch action {
            case .binding:
                if !state.isCameraPresented {
                    state.photoCaptureSource = nil
                }
                return .none
            case .alertAction(.dismiss):
                state.alertCase = nil
                return .none
            case .alertAction:
                return .none
            case let .showAlert(alertCase):
                state.isLoading = false
                state.alertCase = alertCase
                return .send(.alertAction(.present))
            case .onAppear:
                guard state.myMemberId == nil,
                      state.weeklyChallengeDetail == nil,
                      state.weeklyChallengeImageInfos == nil else {
                    return .none
                }

                state.isLoading = true
                let groupId = state.groupId
                let challengeId = state.challengeId
                let groupChallengeId = state.groupChallengeId

                return .run { send in
                    do {
                        try await fetchInitialData(
                            send: send,
                            groupId: groupId,
                            challengeId: challengeId,
                            groupChallengeId: groupChallengeId
                        )
                    } catch {
                        await send(.showAlert(.error(error as? NetworkError ?? .unknown)))
                    }
                }
            case let .initialDataFetched(memberId, detail, imageInfos):
                state.isLoading = false
                state.myMemberId = memberId
                state.weeklyChallengeDetail = detail
                state.weeklyChallengeImageInfos = imageInfos
                return .none
            case .authenticationButtonTapped:
                guard !state.isLoading,
                      state.showsAuthenticationItem else {
                    return .none
                }

                state.isPhotoSourceSheetPresented = true
                return .none
            case .cameraSourceTapped:
                state.isPhotoSourceSheetPresented = false
                state.photoCaptureSource = .camera
                state.isCameraPresented = true
                return .none
            case .gallerySourceTapped:
                state.isPhotoSourceSheetPresented = false
                state.photoCaptureSource = .photoLibrary
                state.isCameraPresented = true
                return .none
            case let .photoCaptureCompleted(result):
                guard !state.isLoading else { return .none }

                state.isCameraPresented = false
                state.photoCaptureSource = nil
                state.isLoading = true
                let groupId = state.groupId
                let groupChallengeId = state.groupChallengeId

                return .run { send in
                    await send(createWeeklyChallengeProof(
                        result: result,
                        groupId: groupId,
                        groupChallengeId: groupChallengeId
                    ))
                }
            case .photoCaptureCancelled:
                state.isCameraPresented = false
                state.photoCaptureSource = nil
                return .none
            case let .weeklyChallengeProofCreated(imageInfos):
                state.isLoading = false
                state.weeklyChallengeImageInfos = imageInfos
                return .run { [output] _ in
                    await output(.weeklyChallengeProofCreated)
                }
            case .snsShareButtonTapped:
                guard !state.isShareButtonDisabled else { return .none }

                state.isLoading = true
                let groupId = state.groupId
                let groupChallengeId = state.groupChallengeId

                return .run { send in
                    do {
                        let share = try await challengeUseCase.shareWeeklyChallenge(
                            groupId: groupId,
                            groupChallengeId: groupChallengeId
                        )
                        await send(.weeklyChallengeShareFinished(share.imageUrl))
                    } catch {
                        let networkError = error as? NetworkError ?? .unknown

                        if case let .serverError(code, _, _) = networkError,
                           code == ServerErrorCode.challenge306.code {
                            await send(.showAlert(.incompleteChallenge))
                        } else {
                            await send(.showAlert(.error(networkError)))
                        }
                    }
                }
            case .weeklyChallengeShareFinished(let imageUrl):
                state.isLoading = false
                return .run { [output] send in
                    await output(.shareWeeklyChallengeImageURL(imageUrl))
                }
            case .backButtonTapped:
                return .run { [router] _ in
                    await router(.back)
                }
            }
        }
    }
}

private extension ChallengeWeeklyDetailFeature {
    func createWeeklyChallengeProof(
        result: CameraCaptureResult,
        groupId: Int,
        groupChallengeId: Int
    ) async -> Action {
        defer {
            try? temporaryImageFileUseCase.removeImage(
                at: result.originalFile.fileURL
            )
        }

        do {
            let imageKey = try await imageUploadUseCase.uploadImage(
                fileURL: result.originalFile.fileURL,
                fileName: result.originalFile.fileName,
                domain: .record
            )
            let request = makeWeeklyChallengeProofCreateRequest(
                imageKey: imageKey,
                normalizedCropRegion: result.normalizedSelectionFrame
            )
            try await challengeUseCase.createWeeklyChallengeProof(
                groupId: groupId,
                groupChallengeId: groupChallengeId,
                request: request
            )
            let imageInfos = try await challengeUseCase.fetchWeeklyChallengeProofs(
                groupId: groupId,
                groupChallengeId: groupChallengeId
            )
            return .weeklyChallengeProofCreated(imageInfos)
        } catch {
            return .showAlert(.error(error as? NetworkError ?? .unknown))
        }
    }

    func makeWeeklyChallengeProofCreateRequest(
        imageKey: String,
        normalizedCropRegion: CGRect
    ) -> WeeklyChallengeProofCreateRequest {
        WeeklyChallengeProofCreateRequest(
            imageKey: imageKey,
            imageCropRegion: WeeklyChallengeProofImageCropRegionRequest(
                x: clampedNormalizedValue(Double(normalizedCropRegion.origin.x)),
                y: clampedNormalizedValue(Double(normalizedCropRegion.origin.y)),
                width: clampedNormalizedValue(Double(normalizedCropRegion.width)),
                height: clampedNormalizedValue(Double(normalizedCropRegion.height))
            )
        )
    }

    func clampedNormalizedValue(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    func fetchInitialData(
        send: Send<Action>,
        groupId: Int,
        challengeId: Int,
        groupChallengeId: Int
    ) async throws {
        var memberId: Int?
        var detail: WeeklyChallengeDetail?
        var imageInfos: [WeeklyChallengeImageInfo]?

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { [authUseCase] in
                let userInfo = try await authUseCase.getUserInfo(needUpdateKeyChain: false)
                memberId = userInfo.memberId
            }
            group.addTask { [challengeUseCase] in
                detail = try await challengeUseCase.fetchWeeklyChallengeDetail(
                    challengeId: challengeId
                )
            }
            group.addTask { [challengeUseCase] in
                imageInfos = try await challengeUseCase.fetchWeeklyChallengeProofs(
                    groupId: groupId,
                    groupChallengeId: groupChallengeId
                )
            }

            do {
                for try await _ in group {}
            } catch {
                group.cancelAll()
                throw error
            }

            guard let memberId,
                  let detail,
                  let imageInfos else {
                throw NetworkError.invalidResponse
            }

            await send(.initialDataFetched(
                memberId: memberId,
                detail: detail,
                imageInfos: imageInfos
            ))
        }
    }
}
