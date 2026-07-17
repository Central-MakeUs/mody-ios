//
//  GroupSettingsView.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import ComposableArchitecture
import SwiftUI

public struct GroupSettingsView: View {
    private let store: StoreOf<GroupSettingsFeature>

    public init(store: StoreOf<GroupSettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        MyPageDetailContent(title: "그룹 설정") {
            store.send(.backButtonTapped)
        }
    }
}
