//
//  ProfileView.swift
//  MyPage
//
//  Created by 김동준 on 7/12/26.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct ProfileView: View {
    private let store: StoreOf<ProfileFeature>

    public init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }

    public var body: some View {
        profileBody
            .mLoading(isPresent: store.isLoading)
    }
    
    private var profileBody: some View {
        VStack(spacing: 0) {
            ProfileAvatarView(
                imageURL: store.profileImageURL,
                defaultAvatar: store.defaultAvatar,
                size: .init(width: 100, height: 100),
                hasStroke: true
            )

            Text("ProfileView")
            
            Button {
                store.send(.backButtonTapped)
            } label: {
                Text("뒤로가기")
            }

            Button {
                store.send(.logoutButtonTapped)
            } label: {
                Text("로그아웃")
            }
        }
    }
}
