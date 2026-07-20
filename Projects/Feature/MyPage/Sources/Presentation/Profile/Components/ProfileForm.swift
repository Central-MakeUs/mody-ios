//
//  ProfileForm.swift
//  MyPage
//
//  Created by 김동준 on 7/19/26.
//

import DesignSystem
import SwiftUI

struct ProfileForm: View {
    @Binding private var name: String
    @FocusState private var isNameFieldFocused: Bool

    private let displayedBirthDate: String
    private let maxNameCount: Int
    private let isNameValid: Bool?

    init(
        name: Binding<String>,
        displayedBirthDate: String,
        maxNameCount: Int,
        isNameValid: Bool?
    ) {
        self._name = name
        self.displayedBirthDate = displayedBirthDate
        self.maxNameCount = maxNameCount
        self.isNameValid = isNameValid
    }

    var body: some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 12) {
                fieldTitle("이름")

                MTextField(
                    $name,
                    placeholder: "이름을 입력해주세요",
                    cursorColor: .main,
                    focusedUnderlineColor: .main,
                    hasStroke: true,
                    strokeColor: nameFieldStrokeColor,
                    hasClearButton: !name.isEmpty,
                    errorMessage: "14자 이내로 적어주세요",
                    maxCount: maxNameCount,
                    isValid: isNameValid,
                    focus: $isNameFieldFocused
                )
            }

            VStack(alignment: .leading, spacing: 12) {
                fieldTitle("생년월일")

                MText(
                    displayedBirthDate,
                    style: .b4,
                    color: .gray4,
                    alignment: .leading
                )
                .greedyWidth(.leading)
                .padding(12)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray2, lineWidth: 1)
                }
            }
        }
    }
}

private extension ProfileForm {
    var nameFieldStrokeColor: Color {
        guard isNameValid != false else { return .systemError }

        return isNameFieldFocused ? .main : .gray2
    }

    func fieldTitle(_ title: String) -> some View {
        MText(
            title,
            style: .b7,
            color: .gray8,
            alignment: .leading
        )
    }
}
