//
//  MainTab.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import DesignSystem

public enum MainTab: Int, CaseIterable {
    case feed = 0
    case challenge = 1
    case myPage = 2
}

extension MainTab {
    var title: String {
        switch self {
        case .feed:
            "피드"
        case .challenge:
            "챌린지"
        case .myPage:
            "마이"
        }
    }

    var image: UIImage? {
        switch self {
        case .feed:
            .icFeed
        case .challenge:
            .icAward
        case .myPage:
            .icProfile
        }
    }
}
