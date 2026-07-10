//
//  OnBoardingBuilder.swift
//  OnBoarding
//
//  Created by 김동준 on 6/25/26
//

import UIKit
import SwiftUI
import OnBoardingInterface
import ComposableArchitecture

public struct OnBoardingBuilder: OnBoardingBuildable {
    private let makeOnBoardingFeature: (OnBoardingRouter) -> OnBoardingFeature

    public init(
        makeOnBoardingFeature: @escaping (OnBoardingRouter) -> OnBoardingFeature
    ) {
        self.makeOnBoardingFeature = makeOnBoardingFeature
    }

    @MainActor
    public func makeOnBoardingViewController(router: OnBoardingRouter) -> UIViewController {
        let view = OnBoardingView(
            store: .init(initialState: .init()) {
                makeOnBoardingFeature(router)
            }
        )

        return UIHostingController(rootView: view)
    }
}
