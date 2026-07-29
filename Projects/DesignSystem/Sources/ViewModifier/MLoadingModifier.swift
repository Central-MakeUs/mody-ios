//
//  MLoadingModifier.swift
//  DesignSystem
//
//  Created by 김동준 on 7/2/26
//

import SwiftUI

struct MLoadingModifier: ViewModifier {
    let isPresent: Bool

    init(isPresent: Bool) {
        self.isPresent = isPresent
    }

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresent {
                ZStack {
                    MLoadingIndicatorView()
                }
                .greedyFrame()
                .background(Color.black.opacity(0.6))
            }
        }
    }
}

// TODO: Lottie 나오면 수정
public struct MLoadingIndicatorView: View {
    public init() {}

    public var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(.gray)
            .scaleEffect(1.2)
    }
}
