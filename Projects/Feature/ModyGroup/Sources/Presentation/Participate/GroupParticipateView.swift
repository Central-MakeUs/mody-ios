//
//  GroupParticipateView.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import Base
import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct GroupParticipateView: View {
    @Bindable private var store: StoreOf<GroupParticipateFeature>
    @FocusState private var isCodeFieldFocused: Bool
    
    public init(store: StoreOf<GroupParticipateFeature>) {
        self.store = store
    }
    
    public var body: some View {
        participateBody
            .background(Color.systemWhite)
            .navigationBarBackButtonHidden()
            .mLoading(isPresent: store.isLoading)
            .mAlert(store.scope(state: \.alertState, action: \.alertAction)) {
                alertView
            }
    }
    
    private var participateBody: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    if store.showsBackButton {
                        MNavigationBar(
                            onBackTap: { store.send(.backButtonTapped) }
                        )
                    }
                    
                    contentsView
                        .padding(.top, store.showsBackButton ? 24 : 72)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }
            }
            
            Spacer()
            
            createGroupArea
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
    }
}

private extension GroupParticipateView {
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

private extension GroupParticipateView {
    var contentsView: some View {
        VStack(spacing: 0) {
            titleSection
            
            codeTextField
                .padding(.top, 48)
            
            participateButton
                .padding(.top, 16)
            
            if let errorMessage = store.joinError?.message {
                errorMessageView(errorMessage)
                    .padding(.top, 12)
            }
        }
    }
}

private extension GroupParticipateView {
    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MText(
                store.showSignUpDoneContents ? "회원가입 완료!" : "그룹 참여하기",
                style: .h2,
                color: .gray10,
                alignment: .leading
            )
            
            VStack(alignment: .leading, spacing: 0) {
                descriptionView
                
                MText(
                    "건강한 다이어트 습관을 길러보세요!",
                    style: .b7,
                    color: .gray6
                )
            }
        }
        .greedyWidth(.leading)
    }
    
    var descriptionView: some View {
        (
            Text(prefixContents)
                .font(ModyTypography.b7.token.swiftUIFont)
                .foregroundStyle(Color.gray6)
            + Text("모디")
                .font(ModyTypography.b5.token.swiftUIFont)
                .foregroundStyle(Color.main0)
            + Text("에서")
                .font(ModyTypography.b7.token.swiftUIFont)
                .foregroundStyle(Color.gray6)
        )
    }
    
    var prefixContents: String {
        store.showSignUpDoneContents
        ? "이제 친구들과 함께, "
        : "친구들과 함께, "
    }
}

private extension GroupParticipateView {
    var codeTextField: some View {
        MTextField(
            $store.inviteCode,
            placeholder: "코드를 입력해주세요",
            isValid: store.isInviteCodeValid,
            focus: $isCodeFieldFocused
        )
    }
    
    var participateButton: some View {
        MButton(
            "그룹 참여하기",
            style: store.isParticipateButtonEnabled ? .primary : .gray,
            isDisabled: !store.isParticipateButtonEnabled,
            horizontalPadding: 0,
            verticalPadding: 13,
            maxWidth: .infinity
        ) {
            isCodeFieldFocused = false
            store.send(.participateButtonTapped)
        }
    }
    
    func errorMessageView(_ text: String) -> some View {
        MText(
            text,
            style: .c2,
            color: .systemError
        )
        .padding(.leading, 8)
        .greedyWidth(.leading)
    }
}

private extension GroupParticipateView {
    var createGroupArea: some View {
        VStack(spacing: 12) {
            MText(
                "초대받은 그룹이 없나요?",
                style: .c2,
                color: .gray7
            )

            MButton(
                "새로운 그룹 만들기",
                style: .black,
                horizontalPadding: 0,
                verticalPadding: 13,
                maxWidth: .infinity
            ) {
                store.send(.createButtonTapped)
            }
        }
    }
}
