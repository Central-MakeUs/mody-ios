//
//  DefaultAvatar.swift
//  CommonDomain
//
//  Created by 김동준 on 7/16/26.
//

public enum DefaultAvatar: CaseIterable, Equatable, Sendable {
    case poutBlack
    case poutLight
    case smileBlack
    case smileLight
    case surpriseBlack
    case surpriseLight

    public static func random() -> Self {
        allCases.randomElement() ?? .poutBlack
    }
}
