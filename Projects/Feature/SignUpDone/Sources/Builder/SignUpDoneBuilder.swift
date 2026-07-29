//
//  SignUpDoneBuilder.swift
//  SignUpDone
//
//  Created by 김동준 on 6/26/26
//

import UIKit
import SwiftUI
import SignUpDoneInterface
import ComposableArchitecture

public struct SignUpDoneBuilder: SignUpDoneBuildable {
    private let makeSignUpDoneRootFeature: (SignUpDoneRouter) -> SignUpDoneRootFeature

    public init(
        makeSignUpDoneRootFeature: @escaping (SignUpDoneRouter) -> SignUpDoneRootFeature
    ) {
        self.makeSignUpDoneRootFeature = makeSignUpDoneRootFeature
    }

    @MainActor
    public func makeSignUpDoneViewController(router: SignUpDoneRouter) -> UIViewController {
        let view = SignUpDoneRootView(
            store: .init(initialState: .init()) {
                makeSignUpDoneRootFeature(router)
            }
        )

        return UIHostingController(rootView: view)
    }
}
