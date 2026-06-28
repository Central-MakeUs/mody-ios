//
//  SignInView.swift
//  SignIn
//
//  Created by 김동준 on 6/25/26
//

import SwiftUI
import ComposableArchitecture

public struct SignInView: View {
    private let store: StoreOf<SignInFeature>
    
    public init(store: StoreOf<SignInFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Text("Hello, SignInView~")
            Button {
                store.send(.mainButtonTapped)
            } label: {
                Text("Main 으로 가기")
                    .padding()
                    .background(.brown)
            }
            
            Button {
                store.send(.onBoardingButtonTapped)
            } label: {
                Text("OnBoarding 으로 가기")
                    .padding()
                    .background(.cyan)
            }
        }
    }
}
