//
//  ProfileView.swift
//  MyPage
//
//  Created by 김동준 on 7/12/26.
//

import SwiftUI
import ComposableArchitecture

public struct ProfileView: View {
    private let store: StoreOf<ProfileFeature>

    public init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }

    public var body: some View {
        profileBody
    }
    
    private var profileBody: some View {
        VStack(spacing: 0) {
            Text("ProfileView")
            
            Button {
                store.send(.backButtonTapped)
            } label: {
                Text("뒤로가기")
            }
        }
    }
}
