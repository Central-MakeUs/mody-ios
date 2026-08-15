//
//  ChallengeWeeklyDetailView.swift
//  Challenge
//
//  Created by 김동준 on 8/12/26.
//

import Base
import CommonDomain
import ComposableArchitecture
import CoreCameraInterface
import CoreModyImageInterface
import DesignSystem
import SwiftUI

struct ChallengeWeeklyDetailView: View {
    @Bindable private var store: StoreOf<ChallengeWeeklyDetailFeature>
    private let imageLoader: RemoteImageLoading
    private let cameraCaptureBuilder: CameraCaptureBuildable
    private let horizontalPadding: CGFloat = 24
    private let gridSpacing: CGFloat = 10

    init(
        store: StoreOf<ChallengeWeeklyDetailFeature>,
        imageLoader: RemoteImageLoading,
        cameraCaptureBuilder: CameraCaptureBuildable
    ) {
        self.store = store
        self.imageLoader = imageLoader
        self.cameraCaptureBuilder = cameraCaptureBuilder
    }

    var body: some View {
        challengeWeeklyDetailBody
            .background(Color.systemWhite)
            .animation(
                .easeInOut(duration: 0.22),
                value: store.weeklyChallengeImageInfos != nil
            )
            .onAppear { store.send(.onAppear) }
            .mLoading(isPresent: store.isLoading)
            .mAlert(store.scope(state: \.alertState, action: \.alertAction)) {
                alertView
            }
            .sheet(isPresented: $store.isPhotoSourceSheetPresented) {
                MPhotoSourceSheetView(
                    onCameraTap: { store.send(.cameraSourceTapped) },
                    onGalleryTap: { store.send(.gallerySourceTapped) }
                )
                .presentationDetents([
                    .height(max(
                        0,
                        200 - DeviceSizeManager.shared.bottomSafeAreaInset
                    ))
                ])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(36)
                .background(Color.systemWhite)
            }
            .fullScreenCover(isPresented: $store.isCameraPresented) {
                if let source = store.photoCaptureSource {
                    ChallengeWeeklyCameraCaptureView(
                        source: source,
                        cropSize: CGSize(width: itemSize, height: itemSize),
                        cameraCaptureBuilder: cameraCaptureBuilder,
                        onComplete: { store.send(.photoCaptureCompleted($0)) },
                        onCancel: { store.send(.photoCaptureCancelled) }
                    )
                    .ignoresSafeArea()
                }
            }
    }
}

private extension ChallengeWeeklyDetailView {
    var challengeWeeklyDetailBody: some View {
        challengeWeeklyDetailContents(itemSize: itemSize)
    }

    var itemSize: CGFloat {
        let contentWidth = DeviceSizeManager.shared.maxWidth - (horizontalPadding * 2)
        return max((contentWidth - gridSpacing) / 2, 0)
    }

    func challengeWeeklyDetailContents(itemSize: CGFloat) -> some View {
        VStack(spacing: 0) {
            MNavigationBar(
                title: "주간 챌린지",
                onBackTap: { store.send(.backButtonTapped) }
            )

            if let detail = store.weeklyChallengeDetail,
               let proofs = store.weeklyChallengeImageInfos,
               store.myMemberId != nil {
                ScrollView {
                    VStack(spacing: 12) {
                        ChallengeWeeklyDetailHeader(detail: detail)

                        ChallengeWeeklyProofGrid(
                            itemSize: itemSize,
                            proofs: proofs,
                            showsAuthenticationItem: store.showsAuthenticationItem,
                            imageLoader: imageLoader,
                            onAuthenticationTap: {
                                store.send(.authenticationButtonTapped)
                            }
                        )
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }

                MButton(
                    "SNS에 공유하기",
                    style: store.isShareButtonDisabled ? .gray : .black,
                    isDisabled: store.isShareButtonDisabled,
                    horizontalPadding: 0,
                    verticalPadding: 13,
                    maxWidth: .infinity
                ) {
                    store.send(.snsShareButtonTapped)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 20)
            } else {
                Spacer()
            }
        }
    }

    @ViewBuilder
    var alertView: some View {
        if let alertCase = store.alertCase {
            switch alertCase {
            case .incompleteChallenge:
                MAlertContentView(
                    title: "알림",
                    contents: "공유 기능은 챌린지를 완료한 뒤 가능합니다.",
                    trailingButton: MAlertButton("확인") {
                        store.send(.alertAction(.dismiss))
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
