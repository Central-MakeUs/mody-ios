//
//  SplashBuilder.swift
//  Splash
//
//  Created by 김동준 on 6/25/26
//

import UIKit
import SwiftUI
import SplashInterface
import ComposableArchitecture

public struct SplashBuilder: SplashBuildable {
    private let makeSplashFeature: (SplashRouter) -> SplashFeature

    public init(
        makeSplashFeature: @escaping (SplashRouter) -> SplashFeature
    ) {
        self.makeSplashFeature = makeSplashFeature
    }

    @MainActor
    public func makeSplashViewController(router: SplashRouter) -> UIViewController {
        let store: StoreOf<SplashFeature> = .init(initialState: SplashFeature.State()) {
            makeSplashFeature(router)
        }
        let view = SplashView(store: store)

        return UIHostingController(rootView: view)
    }
}
