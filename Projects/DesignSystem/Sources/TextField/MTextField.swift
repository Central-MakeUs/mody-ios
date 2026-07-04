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
        self.keyboardType = keyboardType
        self.onSubmit = onSubmit
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            MText(
                placeholder,
                style: .b4,
                color: placeholderColor,
                alignment: .leading
            )
            .padding(.vertical, token.verticalPadding + additionalVerticalPadding)
            .opacity(text.isEmpty ? 1 : 0)
            .allowsHitTesting(false)

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
        .padding(.horizontal, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(isFocused ? focusedUnderlineColor : underlineColor)
                .frame(height: 1)
        }
    }
}

private extension MTextField {
    
}
