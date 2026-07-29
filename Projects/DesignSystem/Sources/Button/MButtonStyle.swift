//
//  MButtonStyle.swift
//  DesignSystem
//
//  Created by 김동준 on 7/5/26
//

import SwiftUI

public enum MButtonStyle {
    case primary
    case gray
    case black
}

extension MButtonStyle {
    var backgroundColor: Color {
        switch self {
        case .primary:
            return .main
        case .gray:
            return .gray2
        case .black:
            return .gray10
        }
    }

    var textColor: Color {
        switch self {
        case .primary:
            return .gray10
        case .gray:
            return .gray5
        case .black:
            return .systemWhite
        }
    }
}
