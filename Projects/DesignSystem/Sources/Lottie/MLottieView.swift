//
//  MLottieView.swift
//  DesignSystem
//
//  Created by 김동준 on 8/18/26.
//

import Lottie
import SwiftUI

public struct MLottieView: View {
    private let animation: LottieAnimation?
    private let loopMode: LottieLoopMode
    private let speed: CGFloat

    public init(
        _ asset: AnimationAsset,
        loopMode: LottieLoopMode = .loop,
        speed: CGFloat = 1.0
    ) {
        animation = asset.animation
        self.loopMode = loopMode
        self.speed = speed
    }

    public var body: some View {
        LottieView(animation: animation)
            .configure { animationView in
                animationView.loopMode = loopMode
                animationView.animationSpeed = speed
            }
            .playing()
    }
}
