//
//  SkeletonView.swift
//  DesignSystem
//
//  Created by 김동준 on 7/16/26.
//

import SwiftUI

public struct SkeletonView: View {
    private let width: CGFloat
    private let height: CGFloat
    private let cornerRadius: CGFloat = 4
    private let animationDuration: TimeInterval = 1.2

    @State private var phase: CGFloat = 0

    public init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray2)
            .frame(width: width, height: height)
            .overlay {
                LinearGradient(
                    colors: [.gray2, .gray1, .gray2],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: -width + (phase * width * 2))
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .onAppear {
                withAnimation(
                    .linear(duration: animationDuration)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}
