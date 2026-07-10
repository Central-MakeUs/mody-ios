//
//  MyPageView.swift
//  MyPage
//
//  Created by 김동준 on 6/30/26
//

import SwiftUI
import MyPageInterface

public struct MyPageView: View {
    private let route: @MainActor (MyPageRoute) -> Void

    public init(route: @escaping @MainActor (MyPageRoute) -> Void) {
        self.route = route
    }

    public var body: some View {
        VStack(spacing: 0) {
            Text("Hello, MyPageView~")
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
