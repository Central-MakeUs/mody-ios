//
//  GroupCreateView.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import Base
import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct GroupCreateView: View {
    @Bindable private var store: StoreOf<GroupCreateFeature>
    @FocusState private var isNameFieldFocused: Bool
    
    public init(store: StoreOf<GroupCreateFeature>) {
        self.store = store
    }
    
    public var body: some View {
        creationBody
            .background(Color.systemWhite)
            .navigationBarBackButtonHidden()
            .overlay {
                if store.isLoading {
                    GroupCreateLoadingOverlay()
                }
            }
            .mAlert(store.scope(state: \.alertState, action: \.alertAction)) {
                alertView
            }
            .onAppear {
                isNameFieldFocused = true
            }
    }
    
    private var creationBody: some View {
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

            nextButton
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
    }
}

private extension GroupCreateView {
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

private extension GroupCreateView {
    var contentsView: some View {
        VStack(spacing: 0) {
            titleSection

            nameTextField
                .padding(.top, 48)
        }
    }
}

private extension GroupCreateView {
    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MText(
                "그룹 이름을 정해볼까요?",
                style: .h2,
                color: .gray10,
                alignment: .leading
            )

            descriptionView
        }
        .greedyWidth(.leading)
    }

    var descriptionView: some View {
        (
            Text("친구들과 함께할 그룹의 이름이에요.\n")
                .font(ModyTypography.b7.token.swiftUIFont)
                .foregroundStyle(Color.gray6)
            + Text("최대 8명")
                .font(ModyTypography.b5.token.swiftUIFont)
                .foregroundStyle(Color.main0)
            + Text("까지 초대할 수 있어요!")
                .font(ModyTypography.b7.token.swiftUIFont)
                .foregroundStyle(Color.gray6)
        )
        .greedyWidth(.leading)
    }
}

private extension GroupCreateView {
    var nameTextField: some View {
        MTextField(
            $store.groupName,
            placeholder: "그룹 이름을 입력해주세요",
            hasClearButton: !store.groupName.isEmpty,
            errorMessage: store.groupNameErrorMessage,
            maxCount: store.maxGroupNameCount,
            isValid: store.isGroupNameValid,
            focus: $isNameFieldFocused
        )
    }

    var nextButton: some View {
        MButton(
            "다음으로",
            style: store.isNextButtonEnabled ? .primary : .gray,
            isDisabled: !store.isNextButtonEnabled,
            horizontalPadding: 0,
            verticalPadding: 13,
            maxWidth: .infinity
        ) {
            isNameFieldFocused = false
            store.send(.nextButtonTapped)
        }
    }
}
