//
//  MButton.swift
//  DesignSystem
//
//  Created by 김동준 on 7/5/26
//

import SwiftUI

public struct MButton: View {
    private let title: String
    private let style: MButtonStyle
    private let isDisabled: Bool
    private let horizontalPadding: CGFloat
    private let verticalPadding: CGFloat
    private let trailingIcon: Image?
    private let action: (() -> Void)?

    public init(
        _ title: String,
        style: MButtonStyle = .primary,
        isDisabled: Bool = false,
        horizontalPadding: CGFloat = 10,
        verticalPadding: CGFloat = 10,
        trailingIcon: Image? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.style = style
        self.isDisabled = isDisabled
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.trailingIcon = trailingIcon
        self.action = action
    }

    public var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 6) {
                MText(
                    title,
                    style: .b6,
                    color: currentTextColor
                )

                if let trailingIcon {
                    trailingIcon
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
            .foregroundStyle(currentTextColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(currentBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isDisabled)
    }
}

private extension MButton {
    var currentBackgroundColor: Color {
        switch style {
        case .primary:
            return .main
        case .gray:
            return .gray2
        case .black:
            return .gray10
        }
    }

    var currentTextColor: Color {
        switch style {
        case .primary:
            return .gray10
        case .gray:
            return .gray5
        case .black:
            return .systemWhite
        }
    }
}
