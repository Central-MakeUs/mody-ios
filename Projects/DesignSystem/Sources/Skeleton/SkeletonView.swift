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

    @State private var phase: CGFloat = 0

    public init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }

    public var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.gray2)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [.gray2, .gray1, .gray2],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(
                            x: -geometry.size.width + (phase * geometry.size.width * 2)
                        )
                        .mask(
                            RoundedRectangle(cornerRadius: cornerRadius)
                        )
                )
        }
        .frame(width: width, height: height)
        .onAppear {
            withAnimation(
                .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
            ) {
                phase = 1
            }
        }
    }
}
