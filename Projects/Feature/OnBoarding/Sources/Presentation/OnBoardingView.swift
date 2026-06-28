//
//  OnBoardingView.swift
//  OnBoarding
//
//  Created by 김동준 on 6/25/26
//

import SwiftUI
import ComposableArchitecture

public struct OnBoardingView: View {
    var store: StoreOf<OnBoardingFeature>
    
    public var body: some View {
        VStack(spacing: 0) {
            Text("OnBoarding!!")
            Button {
                store.send(.signUpDoneButtonTapped)
            } label: {
                Text("SignUpDone 으로 ㄱㄱ")
            }
        }
    }
}
