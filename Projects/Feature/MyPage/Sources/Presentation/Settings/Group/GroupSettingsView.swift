//
//  GroupSettingsView.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import Base
import CommonDomain
import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct GroupSettingsView: View {
    private let store: StoreOf<GroupSettingsFeature>

    public init(store: StoreOf<GroupSettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        groupSettingBody
            .background(Color.systemWhite)
            .onAppear { store.send(.onAppear) }
            .mLoading(isPresent: store.isLoading)
            .mAlert(store.scope(state: \.alertState, action: \.alertAction)) {
                alertView
            }
    }

    private var groupSettingBody: some View {
        VStack(spacing: 0) {
            MNavigationBar(
                title: "그룹 설정",
                onBackTap: { store.send(.backButtonTapped) }
            )

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(store.groups, id: \.groupId) { group in
                        groupRow(
                            group,
                            showsDivider: group.groupId != store.groups.last?.groupId
                        )
                    }
                }
            }
        }
    }
}

private extension GroupSettingsView {
    func groupRow(
        _ group: GroupModel,
        showsDivider: Bool
    ) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 4) {
                MText(
                    group.name,
                    style: .b3,
                    color: .gray9,
                    alignment: .leading
                )

                MText(
                    "그룹",
                    style: .c2,
                    color: .gray5,
                    alignment: .leading
                )
            }

            Spacer()

            exitButton(groupID: group.groupId)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Color.gray1
                    .frame(height: 1)
            }
        }
    }

    func exitButton(groupID: Int) -> some View {
        Button {
            store.send(.exitButtonTapped(groupID: groupID))
        } label: {
            MText(
                "그룹 나가기",
                style: .c1,
                color: .systemWhite
            )
            .vPadding(7)
            .hPadding(12)
            .background(Color.gray3)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

private extension GroupSettingsView {
    @ViewBuilder
    var alertView: some View {
        if let alertCase = store.alertCase {
            switch alertCase {
            case .exitConfirmation:
                MAlertContentView(
                    title: "정말 그룹에서 나가실건가요?",
                    contents: "그룹에서 나가면 모든 정보가 사라져요.",
                    leadingButton: MAlertButton("취소", style: .gray) {
                        store.send(.alertAction(.dismiss))
                    },
                    trailingButton: MAlertButton("그룹 나가기") {
                        store.send(.exitConfirmationTapped)
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
