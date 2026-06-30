//
//  MainTab.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import UIKit

public enum MainTab: Int, CaseIterable {
    case dashboard = 0
    case myPage = 1
}

extension MainTab {
    var title: String {
        switch self {
        case .dashboard:
            "홈"
        case .myPage:
            "마이"
        }
    }

    var normalImage: UIImage? {
        switch self {
        case .dashboard:
            .add
        case .myPage:
            .checkmark
        }
    }

    var selectedImage: UIImage? {
        normalImage
    }
}
