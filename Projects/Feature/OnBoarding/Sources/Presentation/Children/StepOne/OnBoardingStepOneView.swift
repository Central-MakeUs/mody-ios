//
//  OnBoardingStepOneView.swift
//  OnBoarding
//
//  Created by 김동준 on 7/2/26
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct OnBoardingStepOneView: View {
    @Bindable private var store: StoreOf<OnBoardingStepOneFeature>

    public init(store: StoreOf<OnBoardingStepOneFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            titleText

            nicknameTextField
                .padding(.top, 48)

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

private extension OnBoardingStepOneView {
    var titleText: some View {
        MText(
            "모디에서 불리고 싶은\n이름을 알려주세요",
            style: .h2,
            color: .gray10,
            lineLimit: 2,
            alignment: .leading
        )
        .greedyWidth(.leading)
    }

    var nicknameTextField: some View {
        MTextField(
            $store.nickname,
            placeholder: "이름 또는 별명을 입력해주세요",
            hasClearButton: store.hasClearButton,
            errorMessage: "14자 이내로 적어주세요",
            maxCount: store.maxNicknameCount,
            isValid: store.isNicknameValid
        )
    }
}
