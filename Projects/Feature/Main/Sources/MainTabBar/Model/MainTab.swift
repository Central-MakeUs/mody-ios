//
//  MainTab.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import UIKit

public enum MainTab: Int, CaseIterable {
    case dashboard = 0
    case challenge = 1
    case myPage = 2
}

extension MainTab {
    var title: String {
        switch self {
        case .dashboard:
            "홈"
        case .challenge:
            "챌린지"
        case .myPage:
            "마이"
        }
    }

    var normalImage: UIImage? {
        switch self {
        case .dashboard:
            .add
        case .challenge:
            UIImage(systemName: "trophy")
        case .myPage:
            .checkmark
        }
    }

    var selectedImage: UIImage? {
        normalImage
    }
}
