//
//  HealthDataSettingsView.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import ComposableArchitecture
import SwiftUI

public struct HealthDataSettingsView: View {
    private let store: StoreOf<HealthDataSettingsFeature>

    public init(store: StoreOf<HealthDataSettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        MyPageDetailContent(title: "건강 데이터 연동 설정") {
            store.send(.backButtonTapped)
        }
    }
}
