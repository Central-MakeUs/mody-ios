//
//  GroupInviteView.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import SwiftUI
import UIKit
import ComposableArchitecture
import DesignSystem

public struct GroupInviteView: View {
    @Bindable private var store: StoreOf<GroupInviteFeature>
    @FocusState private var isCodeFieldFocused: Bool
    
    public init(store: StoreOf<GroupInviteFeature>) {
        self.store = store
    }
    
    public var body: some View {
        inviteBody
            .background(Color.systemWhite)
            .navigationBarBackButtonHidden()
            .mLoading(isPresent: store.isLoading)
    }

    private var inviteBody: some View {
        VStack(spacing: 0) {
            ScrollView {
                contentsView
                    .padding(.top, 72)
                    .padding(.horizontal, 24)
            }

            Spacer()

            doneButton
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
    }
}

private extension GroupInviteView {
    var contentsView: some View {
        VStack(spacing: 0) {
            titleSection

            inviteCodeField
                .padding(.top, 48)

            shareButton
                .padding(.top, 16)

            if store.isCodeCopied {
                copyMessageView
                    .padding(.top, 12)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: store.isCodeCopied)
    }
}

private extension GroupInviteView {
    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MText(
                "그룹에 함께할 친구를\n초대해보세요!",
                style: .h2,
                color: .gray10,
                lineLimit: 2,
                alignment: .leading
            )

            MText(
                "코드를 클릭해 복사하거나 카카오톡으로 공유하세요.",
                style: .b7,
                color: .gray6,
                alignment: .leading
            )
        }
        .greedyWidth(.leading)
    }
}

private extension GroupInviteView {
    var inviteCodeField: some View {
        HStack(spacing: 0) {
            MTextField(
                $store.inviteCode,
                placeholder: "코드를 입력해주세요",
                underlineColor: .clear,
                focusedUnderlineColor: .clear,
                focus: $isCodeFieldFocused
            )
            .frame(maxWidth: .infinity)
            
            Button {
                isCodeFieldFocused = false
                if !store.inviteCode.isEmpty {
                    UIPasteboard.general.string = store.inviteCode
                }
                store.send(.copyButtonTapped)
            } label: {
                MText(
                    "코드 복사",
                    style: .c2,
                    color: .gray6
                )
                .hPadding(8)
                .vPadding(14)
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.gray2)
                .frame(height: 1)
        }
    }
}

private extension GroupInviteView {
    var shareButton: some View {
        MButton(
            "카카오톡으로 공유하기",
            style: .black,
            isDisabled: store.isLoading,
            horizontalPadding: 0,
            verticalPadding: 13,
            maxWidth: .infinity
        ) {
            store.send(.shareButtonTapped)
        }
    }

    var copyMessageView: some View {
        MText(
            "코드가 복사되었어요.",
            style: .c2,
            color: .gray8
        )
        .padding(.leading, 8)
        .greedyWidth(.leading)
    }

    var doneButton: some View {
        MButton(
            "완료",
            style: .primary,
            horizontalPadding: 0,
            verticalPadding: 13,
            maxWidth: .infinity
        ) {
            isCodeFieldFocused = false
            store.send(.doneButtonTapped)
        }
    }
}
