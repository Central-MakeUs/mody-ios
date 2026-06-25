//
//  OnBoardingBuilder.swift
//  OnBoarding
//
//  Created by 김동준 on 6/25/26
//

import UIKit
import SwiftUI
import OnBoardingInterface

public struct OnBoardingBuilder: OnBoardingBuildable {
    public init() {}

    @MainActor
    public func makeOnBoardingViewController(router: OnBoardingRouter) -> UIViewController {
        let view = OnBoardingRootView(
            store: .init(initialState: .init()) {
            OnBoardingRootFeature()
        })

        return UIHostingController(rootView: view)
    }
}
