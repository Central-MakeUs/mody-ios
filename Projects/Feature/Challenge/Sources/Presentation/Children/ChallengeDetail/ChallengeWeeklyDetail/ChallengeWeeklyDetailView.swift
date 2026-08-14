//
//  ChallengeWeeklyDetailView.swift
//  Challenge
//
//  Created by 김동준 on 8/12/26.
//

import Base
import ComposableArchitecture
import CoreModyImageInterface
import DesignSystem
import SwiftUI

struct ChallengeWeeklyDetailView: View {
    private let store: StoreOf<ChallengeWeeklyDetailFeature>
    private let imageLoader: RemoteImageLoading
    private let horizontalPadding: CGFloat = 24
    private let gridSpacing: CGFloat = 10

    init(
        store: StoreOf<ChallengeWeeklyDetailFeature>,
        imageLoader: RemoteImageLoading
    ) {
        self.store = store
        self.imageLoader = imageLoader
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
    }
}

private extension ChallengeWeeklyDetailView {
    var challengeWeeklyDetailBody: some View {
        GeometryReader { proxy in
            let contentWidth = proxy.size.width - (horizontalPadding * 2)
            let itemSize = max(
                (contentWidth - gridSpacing) / 2,
                0
            )
            challengeWeeklyDetailContents(itemSize: itemSize)
        }
    }

    func challengeWeeklyDetailContents(itemSize: CGFloat) -> some View {
        VStack(spacing: 0) {
            MNavigationBar(
                title: "주간 챌린지",
                onBackTap: { store.send(.backButtonTapped) }
            )

            if let detail = store.weeklyChallengeDetail,
               let proofs = store.weeklyChallengeImageInfos,
               let myMemberId = store.myMemberId {
                ScrollView {
                    VStack(spacing: 12) {
                        ChallengeWeeklyDetailHeader(detail: detail)

                        ChallengeWeeklyProofGrid(
                            itemSize: itemSize,
                            proofs: proofs,
                            myMemberId: myMemberId,
                            showsAuthenticationItem: store.showsAuthenticationItem,
                            imageLoader: imageLoader,
                            onAuthenticationTap: {
                                store.send(.authenticationButtonTapped)
                            },
                            onProofTap: { proofId in
                                store.send(.proofTapped(proofId: proofId))
                            }
                        )
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }

                MButton(
                    "SNS에 공유하기",
                    style: .black,
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
            case let .error(networkError):
                CommonErrorAlertView(networkError) {
                    store.send(.alertAction(.dismiss))
                }
            }
        }
    }
}
