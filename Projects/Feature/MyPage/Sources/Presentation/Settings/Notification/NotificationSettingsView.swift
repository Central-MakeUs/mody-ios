//
//  NotificationSettingsView.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import ComposableArchitecture
import SwiftUI

public struct NotificationSettingsView: View {
    private let store: StoreOf<NotificationSettingsFeature>

    public init(store: StoreOf<NotificationSettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        MyPageDetailContent(title: "알림 설정") {
            store.send(.backButtonTapped)
        }
    }
}
