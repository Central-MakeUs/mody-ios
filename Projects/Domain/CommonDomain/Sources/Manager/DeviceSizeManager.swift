//
//  DeviceSizeManager.swift
//  CommonDomain
//
//  Created by 김동준 on 8/15/26.
//

import Foundation

@MainActor
public final class DeviceSizeManager {
    public static let shared = DeviceSizeManager()

    public private(set) var maxWidth: CGFloat = 0
    public private(set) var bottomSafeAreaInset: CGFloat = 0

    private init() {}

    public func update(
        maxWidth: CGFloat,
        bottomSafeAreaInset: CGFloat
    ) {
        self.maxWidth = max(0, maxWidth)
        self.bottomSafeAreaInset = max(0, bottomSafeAreaInset)
    }
}
