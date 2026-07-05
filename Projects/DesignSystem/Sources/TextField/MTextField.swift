//
//  MTextField.swift
//  DesignSystem
//
//  Created by 김동준 on 7/4/26
//

import SwiftUI

public struct MTextField: View {
    @Binding private var text: String

    private let placeholder: String
    private let textColor: Color
    private let placeholderColor: Color
    private let cursorColor: Color
    private let underlineColor: Color
    private let focusedUnderlineColor: Color
    private let hasStroke: Bool
    private let strokeColor: Color
    private let hasClearButton: Bool
    private let errorMessage: String?
    private let maxCount: Int?
    private let isValid: Bool?
    private let keyboardType: UIKeyboardType
    private let onSubmit: (() -> Void)?

    @FocusState private var isFocused: Bool

    private let token: ModyTypographyStyle = ModyTypography.b4.token
    private let additionalVerticalPadding: CGFloat = 12
    
    public init(
        _ text: Binding<String>,
        placeholder: String,
        textColor: Color = .gray10,
        placeholderColor: Color = .gray4,
        cursorColor: Color = .main,
        underlineColor: Color = .gray2,
        focusedUnderlineColor: Color = .main,
        hasStroke: Bool = false,
        strokeColor: Color = .gray2,
        hasClearButton: Bool = false,
        errorMessage: String? = nil,
        maxCount: Int? = nil,
        isValid: Bool? = nil,
        keyboardType: UIKeyboardType = .default,
        onSubmit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.textColor = textColor
        self.placeholderColor = placeholderColor
        self.cursorColor = cursorColor
        self.underlineColor = underlineColor
        self.focusedUnderlineColor = focusedUnderlineColor
        self.hasStroke = hasStroke
        self.strokeColor = strokeColor
        self.hasClearButton = hasClearButton
        self.errorMessage = errorMessage
        self.maxCount = maxCount
        self.isValid = isValid
        self.keyboardType = keyboardType
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(spacing: 8) {
            inputField

            if hasAdditionalInfoView {
                additionalInfoView
            }
        }
    }
}

private extension MTextField {
    var inputField: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                placeholderView
                textFieldView
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            trailingButtons
        }
        .padding(.horizontal, hasStroke ? 12 : 8)
        .overlay {
            if hasStroke {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: 1)
            }
        }
        .overlay(alignment: .bottom) {
            if !hasStroke {
                Rectangle()
                    .fill(isFocused ? focusedUnderlineColor : underlineColor)
                    .frame(height: 1)
            }
        }
    }
}

private extension MTextField {
    var placeholderView: some View {
        MText(
            placeholder,
            style: .b4,
            color: placeholderColor,
            alignment: .leading
        )
        .padding(.vertical, token.verticalPadding + additionalVerticalPadding)
        .opacity(text.isEmpty ? 1 : 0)
        .allowsHitTesting(false)
    }
    
    var textFieldView: some View {
        TextField("", text: $text)
            .font(token.swiftUIFont)
            .foregroundStyle(textColor)
            .kerning(token.letterSpacing)
            .lineSpacing(token.additionalLineSpacing)
            .multilineTextAlignment(.leading)
            .padding(.vertical, token.verticalPadding + additionalVerticalPadding)
            .lineLimit(1)
            .tint(cursorColor)
            .keyboardType(keyboardType)
            .focused($isFocused)
            .onSubmit { onSubmit?() }
    }
}

private extension MTextField {
    var hasAdditionalInfoView: Bool {
        visibleErrorMessage != nil || maxCount != nil
    }

    var additionalInfoView: some View {
        HStack(spacing: 8) {
            if let visibleErrorMessage {
                MText(
                    visibleErrorMessage,
                    style: .c1,
                    color: .systemError,
                    alignment: .leading
                )
            }

            Spacer()

            if let maxCount {
                textCountView(maxCount: maxCount)
            }
        }
        .padding(.horizontal, 8)
    }

    var visibleErrorMessage: String? {
        guard isValid == false else {
            return nil
        }

        return errorMessage
    }

    func textCountView(maxCount: Int) -> some View {
        HStack(spacing: 0) {
            MText(
                "\(text.count)",
                style: currentTextStyle,
                color: currentTextCountColor
            )

            MText(
                "/\(maxCount)",
                style: .c1,
                color: .gray7
            )
        }
    }
    
    var currentTextStyle: ModyTypography {
        return isValid == nil ? .c1 : .b7
    }

    var currentTextCountColor: Color {
        switch isValid {
        case .some(true): .sub
        case .some(false): .systemError
        case .none: .gray7
        }
    }

    @ViewBuilder
    var trailingButtons: some View {
        HStack(spacing: 4) {
            if hasClearButton {
                Button {
                    text = ""
                } label: {
                    Image.icTextClear
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }

            if isValid == false {
                Image.icError24
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
    }
}
