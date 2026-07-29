//
//  ModyTypographyFontWeight.swift
//  DesignSystem
//
//  Created by 김동준 on 7/1/26
//

public enum ModyTypographyFontWeight {
    case bold
    case semiBold
    case medium
    
    public var font: DesignSystemFontConvertible {
        switch self {
        case .bold: DesignSystemFontFamily.Pretendard.bold
        case .semiBold: DesignSystemFontFamily.Pretendard.semiBold
        case .medium: DesignSystemFontFamily.Pretendard.medium
        }
    }
}
