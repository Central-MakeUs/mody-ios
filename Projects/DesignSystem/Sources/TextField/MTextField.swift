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
    private let hasErrorIcon: Bool
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
        hasErrorIcon: Bool = false,
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
        self.hasErrorIcon = hasErrorIcon
        self.keyboardType = keyboardType
        self.onSubmit = onSubmit
    }

    public var body: some View {
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

            if hasErrorIcon {
                Image.icError24
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
    }
}
