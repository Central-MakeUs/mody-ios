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
    private let maxWidth: CGFloat?
    private let trailingIcon: Image?
    private let trailingIconSize: CGSize
    private let trailingIconColor: Color?
    private let action: (() -> Void)?

    public init(
        _ title: String,
        style: MButtonStyle = .primary,
        isDisabled: Bool = false,
        horizontalPadding: CGFloat = 10,
        verticalPadding: CGFloat = 10,
        maxWidth: CGFloat? = nil,
        trailingIcon: Image? = nil,
        trailingIconSize: CGSize = .init(width: 20, height: 20),
        trailingIconColor: Color? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.style = style
        self.isDisabled = isDisabled
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.maxWidth = maxWidth
        self.trailingIcon = trailingIcon
        self.trailingIconSize = trailingIconSize
        self.trailingIconColor = trailingIconColor
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
                    color: style.textColor
                )

                if let trailingIcon {
                    trailingIcon
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: trailingIconSize.width, height: trailingIconSize.height)
                        .optionalForegroundStyle(trailingIconColor)
                }
            }
            .foregroundStyle(style.textColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: maxWidth)
            .background(style.backgroundColor)
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

private extension View {
    func optionalForegroundStyle(_ color: Color?) -> some View {
        modifier(OptionalForegroundStyleModifier(color: color))
    }
}

private struct OptionalForegroundStyleModifier: ViewModifier {
    let color: Color?

    @ViewBuilder
    func body(content: Content) -> some View {
        if let color {
            content.foregroundStyle(color)
        } else {
            content
        }
    }
}
