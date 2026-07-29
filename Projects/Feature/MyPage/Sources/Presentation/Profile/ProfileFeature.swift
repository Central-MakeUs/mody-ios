//
//  ProfileFeature.swift
//  MyPage
//
//  Created by 김동준 on 7/12/26.
//

import ComposableArchitecture
import Base
import CommonDomain
import CoreAuthInterface
import CoreCameraInterface
import CoreModyImageInterface
import Foundation
import MyPageInterface
import ModyLogger

@Reducer
public struct ProfileFeature {
    private let authUseCase: AuthUseCaseProtocol
    private let myPageUseCase: MyPageUseCase
    private let imageUploadUseCase: ImageUploadUseCaseProtocol
    private let temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol
    private let router: @MainActor (MyPageProfileRoute) -> Void
    private let output: @MainActor (MyPageOutput) -> Void

    public init(
        authUseCase: AuthUseCaseProtocol,
        myPageUseCase: MyPageUseCase,
        imageUploadUseCase: ImageUploadUseCaseProtocol,
        temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol,
        router: @escaping @MainActor (MyPageProfileRoute) -> Void,
        output: @escaping @MainActor (MyPageOutput) -> Void
    ) {
        self.authUseCase = authUseCase
        self.myPageUseCase = myPageUseCase
        self.imageUploadUseCase = imageUploadUseCase
        self.temporaryImageFileUseCase = temporaryImageFileUseCase
        self.router = router
        self.output = output
    }

    @ObservableState
    public struct State {
        public enum AlertCase: Equatable {
            case deleteConfirmation
            case deleteCompleted
            case error(NetworkError)
        }

        let maxNameCount = 14
        var isLoading: Bool = false
        var profileImageURL: URL?
        var defaultAvatar: DefaultAvatar
        var socialLoginType: SocialLoginType?
        var name = ""
        var birthDate = ""
        var isPhotoFlowPresented = false
        var isCameraPresented = false
        var photoCaptureSource: CameraCaptureSource?
        var selectedPhoto: CameraCaptureResult?
        var alertCase: AlertCase?
        var alertState = AlertFeature.State()

        var isNameTooLong: Bool {
            name.count > maxNameCount
        }

        var isNameValid: Bool? {
            guard !name.isEmpty else { return nil }
            return !isNameTooLong
        }

        var isSaveButtonEnabled: Bool {
            isNameValid == true && !birthDate.isEmpty && !isLoading
        }

        var displayedBirthDate: String {
            birthDate.replacingOccurrences(of: "-", with: ".")
        }

        public init(
            profileImageURL: URL?,
            defaultAvatar: DefaultAvatar
        ) {
            self.profileImageURL = profileImageURL
            self.defaultAvatar = defaultAvatar
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case alertAction(AlertFeature.Action)
        case showAlert(State.AlertCase)
        case onAppear
        case backButtonTapped
        case saveButtonTapped
        case profileImageTapped
        case photoPresentationDismissed
        case cameraSourceTapped
        case gallerySourceTapped
        case photoCaptureCompleted(CameraCaptureResult)
        case photoCaptureCancelled
        case profileFetched(MyPageProfile)
        case profileFetchFailed(NetworkError)
        case profileUpdated
        case profileUpdateFailed(NetworkError)
        case logoutButtonTapped
        case logoutSuccessfully
        case logoutFailed(NetworkError)
        case deleteAccountButtonTapped
        case deleteAccountCancelButtonTapped
        case deleteAccountConfirmButtonTapped
        case deleteAccountSuccessfully
        case deleteAccountFailed(NetworkError)
        case deleteAccountCompletionButtonTapped
        case routeToSignIn
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.alertState, action: \.alertAction) {
            AlertFeature()
        }

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .alertAction:
                return .none
            case let .showAlert(alertCase):
                state.isLoading = false
                state.alertCase = alertCase
                state.alertState.dismissOnScrimTap = alertCase != .deleteCompleted
                return .send(.alertAction(.present))
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await send(fetchProfile())
                }
            case let .profileFetched(profile):
                state.isLoading = false
                state.socialLoginType = profile.socialLoginType
                state.name = profile.name
                state.birthDate = profile.birthDate
                return .none
            case let .profileFetchFailed(error):
                return .send(.showAlert(.error(error)))
            case .backButtonTapped:
                let selectedPhotoURL = state.selectedPhoto?.originalFile.fileURL
                state.selectedPhoto = nil
                state.isPhotoFlowPresented = false
                state.isCameraPresented = false
                state.photoCaptureSource = nil
                if let selectedPhotoURL {
                    try? temporaryImageFileUseCase.removeImage(at: selectedPhotoURL)
                }

                return .run { [router] _ in
                    await router(.back)
                }
            case .profileImageTapped:
                guard !state.isLoading else { return .none }
                state.isPhotoFlowPresented = true
                return .none
            case .photoPresentationDismissed:
                state.isPhotoFlowPresented = false
                state.isCameraPresented = false
                state.photoCaptureSource = nil
                return .none
            case .cameraSourceTapped:
                state.photoCaptureSource = .camera
                state.isCameraPresented = true
                return .none
            case .gallerySourceTapped:
                state.photoCaptureSource = .photoLibrary
                state.isCameraPresented = true
                return .none
            case let .photoCaptureCompleted(result):
                let previousPhotoURL = state.selectedPhoto?.originalFile.fileURL
                state.selectedPhoto = result
                state.isPhotoFlowPresented = false
                state.isCameraPresented = false
                state.photoCaptureSource = nil

                if let previousPhotoURL {
                    try? temporaryImageFileUseCase.removeImage(at: previousPhotoURL)
                }
                return .none
            case .photoCaptureCancelled:
                state.isPhotoFlowPresented = false
                state.isCameraPresented = false
                state.photoCaptureSource = nil
                return .none
            case .saveButtonTapped:
                guard state.isSaveButtonEnabled else { return .none }

                let nickname = state.name
                let birthDate = state.birthDate
                let selectedPhoto = state.selectedPhoto
                state.isLoading = true

                return .run { send in
                    await send(
                        updateProfile(
                            nickname: nickname,
                            birthDate: birthDate,
                            selectedPhoto: selectedPhoto
                        )
                    )
                }
            case .profileUpdated:
                state.isLoading = false
                state.selectedPhoto = nil
                return .run { [output] send in
                    await output(.profileUpdated)
                    await send(.backButtonTapped)
                }
            case let .profileUpdateFailed(error):
                return .send(.showAlert(.error(error)))
            case .logoutButtonTapped:
                guard !state.isLoading else { return .none }

                state.isLoading = true
                return .run { send in
                    await send(logout())
                }
            case .logoutSuccessfully:
                state.isLoading = false
                return .send(.routeToSignIn)
            case let .logoutFailed(error):
                return .send(.showAlert(.error(error)))
            case .deleteAccountButtonTapped:
                return .send(.showAlert(.deleteConfirmation))
            case .deleteAccountCancelButtonTapped:
                return .send(.alertAction(.dismiss))
            case .deleteAccountConfirmButtonTapped:
                guard !state.isLoading else { return .none }

                state.isLoading = true
                return .merge(
                    .send(.alertAction(.dismiss)),
                    .run { send in
                        await send(deleteAccount())
                    }
                )
            case .deleteAccountSuccessfully:
                return .send(.showAlert(.deleteCompleted))
            case let .deleteAccountFailed(error):
                return .send(.showAlert(.error(error)))
            case .deleteAccountCompletionButtonTapped:
                return .merge(
                    .send(.alertAction(.dismiss)),
                    .send(.routeToSignIn)
                )
            case .routeToSignIn:
                return .run { [router] _ in
                    await router(.routeToSignIn)
                }
            }
        }
    }
}

private extension ProfileFeature {
    func fetchProfile() async -> Action {
        do {
            let profile = try await myPageUseCase.fetchMyPageProfile()
            return .profileFetched(profile)
        } catch {
            return .profileFetchFailed(error as? NetworkError ?? .unknown)
        }
    }

    func updateProfile(
        nickname: String,
        birthDate: String,
        selectedPhoto: CameraCaptureResult?
    ) async -> Action {
        do {
            let imageKey: String?
            if let selectedPhoto {
                imageKey = try await imageUploadUseCase.uploadImage(
                    fileURL: selectedPhoto.originalFile.fileURL,
                    fileName: selectedPhoto.originalFile.fileName,
                    domain: .profile
                )
            } else {
                imageKey = nil
            }

            let request = MyPageProfileUpdateRequest(
                nickname: nickname,
                birthDate: birthDate,
                imageKey: imageKey
            )
            try await myPageUseCase.updateMyPageProfile(request)

            if let selectedPhoto {
                try? temporaryImageFileUseCase.removeImage(
                    at: selectedPhoto.originalFile.fileURL
                )
            }
            return .profileUpdated
        } catch {
            return .profileUpdateFailed(error as? NetworkError ?? .unknown)
        }
    }

    func logout() async -> Action {
        do {
            try await authUseCase.logout()
            return .logoutSuccessfully
        } catch {
            ModyLogger.debug("Logout failed: \(error)")
            return .logoutFailed(error as? NetworkError ?? .unknown)
        }
    }

    func deleteAccount() async -> Action {
        do {
            try await authUseCase.deleteAccount()
            return .deleteAccountSuccessfully
        } catch {
            ModyLogger.debug("Delete account failed: \(error)")
            return .deleteAccountFailed(error as? NetworkError ?? .unknown)
        }
    }
}
