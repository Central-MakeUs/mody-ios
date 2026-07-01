//
//  ModyTypography.swift
//  DesignSystem
//
//  Created by 김동준 on 6/30/26.
//

import UIKit
import SwiftUI

public enum ModyTypography: CaseIterable {
    case h1
    case h2
    case h3
    case b1
    case b2
    case b3
    case b4
    case b5
    case b6
    case c1
    
    public var token: ModyTypographyStyle {
        switch self {
        case .h1: ModyTypographyStyle(weight: .bold, size: 28)
        case .h2: ModyTypographyStyle(weight: .bold, size: 24)
        case .h3: ModyTypographyStyle(weight: .bold, size: 20)
        case .b1: ModyTypographyStyle(weight: .semiBold, size: 22)
        case .b2: ModyTypographyStyle(weight: .semiBold, size: 20)
        case .b3: ModyTypographyStyle(weight: .semiBold, size: 18)
        case .b4: ModyTypographyStyle(weight: .medium, size: 18)
        case .b5: ModyTypographyStyle(weight: .semiBold, size: 16)
        case .b6: ModyTypographyStyle(weight: .medium, size: 16)
        case .c1: ModyTypographyStyle(weight: .medium, size: 14)
        }
    }
}
