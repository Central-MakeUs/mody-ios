//
//  ModyTypography.swift
//  DesignSystem
//
//  Created by 김동준 on 6/30/26.
//

import UIKit

public struct ModyTypography: Equatable, Sendable {
    public enum Weight: Equatable, Sendable {
        case bold
        case semiBold
        case medium
    }

    public let weight: Weight
    public let size: CGFloat
    public let lineHeightRatio: CGFloat
    public let letterSpacing: CGFloat

    public init(
        weight: Weight,
        size: CGFloat,
        lineHeightRatio: CGFloat,
        letterSpacing: CGFloat
    ) {
        self.weight = weight
        self.size = size
        self.lineHeightRatio = lineHeightRatio
        self.letterSpacing = letterSpacing
    }
}

public extension ModyTypography {
    static let h1 = ModyTypography(weight: .bold, size: 28, lineHeightRatio: 1.4, letterSpacing: 0)
    static let h2 = ModyTypography(weight: .bold, size: 24, lineHeightRatio: 1.4, letterSpacing: 0)
    static let h3 = ModyTypography(weight: .bold, size: 20, lineHeightRatio: 1.4, letterSpacing: 0)
    static let b1 = ModyTypography(weight: .semiBold, size: 22, lineHeightRatio: 1.4, letterSpacing: 0)
    static let b2 = ModyTypography(weight: .semiBold, size: 20, lineHeightRatio: 1.4, letterSpacing: 0)
    static let b3 = ModyTypography(weight: .semiBold, size: 18, lineHeightRatio: 1.4, letterSpacing: 0)
    static let b4 = ModyTypography(weight: .medium, size: 18, lineHeightRatio: 1.4, letterSpacing: 0)
    static let b5 = ModyTypography(weight: .semiBold, size: 16, lineHeightRatio: 1.4, letterSpacing: 0)
    static let b6 = ModyTypography(weight: .medium, size: 16, lineHeightRatio: 1.4, letterSpacing: 0)
    static let c1 = ModyTypography(weight: .medium, size: 14, lineHeightRatio: 1.4, letterSpacing: 0)
}
