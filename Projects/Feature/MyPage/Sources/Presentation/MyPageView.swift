//
//  MyPageView.swift
//  MyPage
//
//  Created by 김동준 on 6/30/26
//

import SwiftUI
import ComposableArchitecture

public struct MyPageView: View {
    private let store: StoreOf<MyPageFeature>

    public init(store: StoreOf<MyPageFeature>) {
        self.store = store
    }

    public var body: some View {
        myPageBody
    }
    
    private var myPageBody: some View {
        VStack(spacing: 0) {
            Text("Hello, MyPageView~")
            Button {
                store.send(.profileButtonTapped)
            } label: {
                Text("(임시) 프로필로 이동")
                    .padding()
                    .background(.brown)
            }
        }
    }
}
