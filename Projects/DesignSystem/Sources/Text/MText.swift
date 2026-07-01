//
//  MText.swift
//  DesignSystem
//
//  Created by 김동준 on 7/1/26
//

import SwiftUI

public struct MText: View {
    private let text: String
    private let token: ModyTypographyStyle
    private let color: Color
    private let lineLimit: Int?
    private let underline: Bool
    private let alignment: TextAlignment

    public init(
        _ text: String,
        style: ModyTypography,
        color: Color = .systemBlack,
        lineLimit: Int? = 1,
        underline: Bool = false,
        alignment: TextAlignment = .center
    ) {
        self.text = text
        self.token = style.token
        self.color = color
        self.lineLimit = lineLimit
        self.underline = underline
        self.alignment = alignment
    }

    public var body: some View {
        Text(text)
            .font(token.swiftUIFont)
            .foregroundStyle(color)
            .kerning(token.letterSpacing)
            .underline(underline)
            .lineSpacing(token.additionalLineSpacing)
            .multilineTextAlignment(alignment)
            .lineLimit(lineLimit)
            .truncationMode(.tail)
            .padding(.vertical, token.verticalPadding)
    }
}
