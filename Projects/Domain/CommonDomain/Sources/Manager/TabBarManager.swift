//
//  TabBarManager.swift
//  CommonDomain
//
//  Created by 김동준 on 7/5/26
//

public final class TabBarManager {
    public static let shared = TabBarManager()

    public var isChallengeTabHidden: Bool = false

    private init() {}
}
