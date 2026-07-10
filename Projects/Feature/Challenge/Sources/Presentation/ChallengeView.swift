//
//  ChallengeView.swift
//  Challenge
//
//  Created by 김동준 on 6/30/26
//

import SwiftUI
import ChallengeInterface

public struct ChallengeView: View {
    private let route: @MainActor (ChallengeRoute) -> Void

    public init(route: @escaping @MainActor (ChallengeRoute) -> Void) {
        self.route = route
    }

    public var body: some View {
        VStack(spacing: 0) {
            Text("Hello, ChallengeView~")
            Button {
                route(.temp)
            } label: {
                Text("Temp 으로 가기")
                    .padding()
                    .background(.brown)
            }
        }
    }
}
