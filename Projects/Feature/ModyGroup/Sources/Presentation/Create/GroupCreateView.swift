//
//  GroupCreateView.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct GroupCreateView: View {
    private let store: StoreOf<GroupCreateFeature>
    
    public init(store: StoreOf<GroupCreateFeature>) {
        self.store = store
    }
    
    public var body: some View {
        creationBody
    }
    
    private var creationBody: some View {
        VStack(spacing: 0) {
            if store.showsBackButton {
                MNavigationBar(
                    onBackTap: { store.send(.backButtonTapped) }
                )
            }
            Text("그룹 이름 정하기")
            
            Button("다음") {
                store.send(.nextButtonTapped)
            }
        }
    }
}
