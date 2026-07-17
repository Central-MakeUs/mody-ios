//
//  MyPageView.swift
//  MyPage
//
//  Created by 김동준 on 6/30/26
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct MyPageView: View {
    @Bindable private var store: StoreOf<MyPageFeature>

    public init(store: StoreOf<MyPageFeature>) {
        self.store = store
    }

    public var body: some View {
        myPageBody
            .background(Color.systemWhite)
            .onAppear { store.send(.onAppear) }
            .sheet(
                item: $store.scope(\.weightRecordSheet, action: \.weightRecordSheet)
            ) { store in
                WeightRecordView(store: store)
            }
    }
}

private extension MyPageView {
    private var myPageBody: some View {
        ScrollView {
            VStack(spacing: 0) {
                ProfileSection(
                    imageURL: store.profileImageURL,
                    defaultAvatar: store.defaultAvatar,
                    userInfo: store.userInfo
                ) {
                    store.send(.profileEditButtonTapped)
                }
                .padding(.top, 28)
                .padding(.horizontal, 24)

                WeightSection(weightRecord: store.weightRecord) {
                    store.send(.weightRecordButtonTapped)
                }
                .padding(.top, 28)
                .padding(.horizontal, 24)

                Color.gray1
                    .frame(height: 6)
                    .padding(.top, 20)

                settingsSection
                    .padding(.bottom, 16)
            }
        }
        .scrollIndicators(.hidden)
    }
}

private extension MyPageView {
    var settingsSection: some View {
        VStack(spacing: 0) {
            settingsRow(
                title: "알림 설정",
                action: .notificationSettingsButtonTapped,
                hasDivider: true
            )

            settingsRow(
                title: "그룹 설정",
                action: .groupSettingsButtonTapped,
                hasDivider: true
            )

            settingsRow(
                title: "건강 데이터 연동 설정",
                action: .healthDataSettingsButtonTapped,
                hasDivider: false
            )
        }
    }

    func settingsRow(
        title: String,
        action: MyPageFeature.Action,
        hasDivider: Bool
    ) -> some View {
        Button {
            store.send(action)
        } label: {
            HStack(spacing: 0) {
                MText(
                    title,
                    style: .b4,
                    color: .gray9,
                    alignment: .leading
                )

                Spacer()

                Image.icRightArrow
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray4)
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .overlay(alignment: .bottom) {
                if hasDivider {
                    Rectangle()
                        .fill(Color.gray1)
                        .frame(height: 1)
                }
            }
            .contentShape(Rectangle())
        }
    }
}
