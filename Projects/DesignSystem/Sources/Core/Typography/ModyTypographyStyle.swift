//
//  ModyTypographyStyle.swift
//  DesignSystem
//
//  Created by 김동준 on 7/1/26
//

import UIKit
import SwiftUI

public struct ModyTypographyStyle {
    private let weight: ModyTypographyFontWeight
    private let size: CGFloat
    private let lineHeightRatio: CGFloat
    public let letterSpacing: CGFloat

    public init(
        weight: ModyTypographyFontWeight,
        size: CGFloat,
        lineHeightRatio: CGFloat = 1.4,
        letterSpacing: CGFloat = 0
    ) {
        self.weight = weight
        self.size = size
        self.lineHeightRatio = lineHeightRatio
        self.letterSpacing = letterSpacing
    }
}

public extension ModyTypographyStyle {
    var uiFont: UIFont {
        weight.font.font(size: size)
    }

    var swiftUIFont: Font {
        weight.font.swiftUIFont(size: size)
    }
}

public extension ModyTypographyStyle {
    var lineHeight: CGFloat {
        size * lineHeightRatio
    }

    var additionalLineSpacing: CGFloat {
        max(0, lineHeight - uiFont.lineHeight)
    }

    var verticalPadding: CGFloat {
        additionalLineSpacing / 2
    }
    
    var baselineOffset: CGFloat {
        additionalLineSpacing / 2
    }
}

public extension ModyTypographyStyle {
    func paragraphStyle(
        alignment: NSTextAlignment = .natural,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail
    ) -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.lineSpacing = 0
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        return paragraphStyle
    }
    
    func attributes(
        color: UIColor,
        alignment: NSTextAlignment = .natural,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail,
        underline: Bool = false
    ) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: uiFont,
            .foregroundColor: color,
            .kern: letterSpacing,
            .baselineOffset: baselineOffset,
            .paragraphStyle: paragraphStyle(alignment: alignment, lineBreakMode: lineBreakMode)
        ]
        
        if underline {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        
        return attributes
    }
    
    func attributedString(
        _ text: String,
        color: UIColor,
        alignment: NSTextAlignment = .natural,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail,
        underline: Bool = false
    ) -> NSAttributedString {
        NSAttributedString(
            string: text,
            attributes: attributes(
                color: color,
                alignment: alignment,
                lineBreakMode: lineBreakMode,
                underline: underline
            )
        )
    }
}
