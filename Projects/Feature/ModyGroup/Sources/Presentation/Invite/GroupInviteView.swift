//
//  GroupInviteView.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct GroupInviteView: View {
    private let store: StoreOf<GroupInviteFeature>
    
    public init(store: StoreOf<GroupInviteFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("그룹 초대하기")
            
            Button("공유하기") {
                store.send(.shareButtonTapped)
            }
            
            Button("완료") {
                store.send(.doneButtonTapped)
            }
        }
        .navigationBarBackButtonHidden()
    }
}
