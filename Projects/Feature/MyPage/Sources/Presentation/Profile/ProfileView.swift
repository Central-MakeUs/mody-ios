//
//  ProfileView.swift
//  MyPage
//
//  Created by 김동준 on 7/12/26.
//

import SwiftUI
import Base
import CommonDomain
import ComposableArchitecture
import CoreCameraInterface
import CoreModyImageInterface
import DesignSystem

public struct ProfileView: View {
    @Bindable private var store: StoreOf<ProfileFeature>
    private let imageLoader: RemoteImageLoading
    private let cameraCaptureBuilder: CameraCaptureBuildable

    public init(
        store: StoreOf<ProfileFeature>,
        imageLoader: RemoteImageLoading,
        cameraCaptureBuilder: CameraCaptureBuildable
    ) {
        self.store = store
        self.imageLoader = imageLoader
        self.cameraCaptureBuilder = cameraCaptureBuilder
    }

    public var body: some View {
        profileBody
            .background(Color.systemWhite)
            .onAppear { store.send(.onAppear) }
            .mLoading(isPresent: store.isLoading)
            .mAlert(store.scope(state: \.alertState, action: \.alertAction)) {
                alertView
            }
            .sheet(
                isPresented: $store.isPhotoFlowPresented,
                onDismiss: { store.send(.photoPresentationDismissed) }
            ) {
                MPhotoSourceSheetView(
                    onCameraTap: { store.send(.cameraSourceTapped) },
                    onGalleryTap: { store.send(.gallerySourceTapped) }
                )
                .presentationDetents([
                    .height(max(0, 200 - DeviceSizeManager.shared.bottomSafeAreaInset))
                ])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(36)
            }
            .fullScreenCover(
                isPresented: $store.isCameraPresented,
                onDismiss: { store.send(.photoCaptureCancelled) }
            ) {
                if let source = store.photoCaptureSource {
                    ProfileCameraCaptureView(
                        source: source,
                        cameraCaptureBuilder: cameraCaptureBuilder,
                        onComplete: { store.send(.photoCaptureCompleted($0)) },
                        onCancel: { store.send(.photoCaptureCancelled) }
                    )
                    .ignoresSafeArea()
                }
            }
    }
}

private extension ProfileView {
    private var profileBody: some View {
        VStack(spacing: 0) {
            profileNavigationBar

            ScrollView {
                VStack(spacing: 0) {
                    Button {
                        store.send(.profileImageTapped)
                    } label: {
                        RemoteAvatarView(
                            imageURL: store.profileImageURL,
                            localImage: store.selectedPhoto?.croppedPreviewImage,
                            defaultAvatar: store.defaultAvatar,
                            width: 100,
                            height: 100,
                            hasStroke: true,
                            imageLoader: imageLoader
                        )
                    }
                    .padding(.top, 28)

                    ProfileForm(
                        name: $store.name,
                        displayedBirthDate: store.displayedBirthDate,
                        maxNameCount: store.maxNameCount,
                        isNameValid: store.isNameValid
                    )
                    .padding(.top, 28)
                    .padding(.horizontal, 24)

                    if let socialLoginType = store.socialLoginType {
                        ProfileSocialLoginStatus(type: socialLoginType)
                            .padding(.horizontal, 24)
                            .padding(.top, 32)
                    }

                    Color.gray1
                        .frame(height: 6)
                        .padding(.top, 20)

                    ProfileAccountSections(
                        onLogout: { store.send(.logoutButtonTapped) },
                        onDeleteAccount: { store.send(.deleteAccountButtonTapped) }
                    )
                    .padding(.bottom, 16)
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

private extension ProfileView {
    var profileNavigationBar: some View {
        HStack(spacing: 0) {
            arrowLeftButton

            MText(
                "프로필 설정",
                style: .b6,
                color: .gray9,
                alignment: .leading
            )
            .padding(.leading, 4)

            Spacer()

            Button {
                store.send(.saveButtonTapped)
            } label: {
                MText(
                    "저장",
                    style: .b5,
                    color: .sub
                )
            }
            .vPadding(13)
        }
        .padding(.horizontal, 24)
        .navigationBarBackButtonHidden()
        .background(Color.systemWhite)
    }

    var arrowLeftButton: some View {
        Button {
            store.send(.backButtonTapped)
        } label: {
            Image.icLeftArrow
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.gray8)
        }
        .padding(.vertical, 12)
    }
}

private extension ProfileView {
    @ViewBuilder
    var alertView: some View {
        if let alertCase = store.alertCase {
            switch alertCase {
            case .deleteConfirmation:
                MAlertContentView(
                    title: "정말 모디를 떠나실건가요?",
                    contents: "탈퇴하면 계정 내 모든 정보가 사라져요.",
                    leadingButton: MAlertButton(
                        "취소",
                        style: .gray
                    ) {
                        store.send(.deleteAccountCancelButtonTapped)
                    },
                    trailingButton: MAlertButton("계정 삭제") {
                        store.send(.deleteAccountConfirmButtonTapped)
                    }
                )
            case .deleteCompleted:
                MAlertContentView(
                    title: "탈퇴 처리가 완료되었어요.",
                    contents: "마음이 바뀐다면 꼭 다시 찾아와주세요!",
                    trailingButton: MAlertButton("확인") {
                        store.send(.deleteAccountCompletionButtonTapped)
                    }
                )
            case let .error(networkError):
                CommonErrorAlertView(networkError) {
                    store.send(.alertAction(.dismiss))
                }
            }
        }
    }
}
