//
//  SignInBuilder.swift
//  SignIn
//
//  Created by 김동준 on 6/25/26
//

import UIKit
import SwiftUI
import SignInInterface
import ComposableArchitecture

public struct SignInBuilder: SignInBuildable {
    private let makeSignInFeature: (SignInRouter) -> SignInFeature

    public init(
        makeSignInFeature: @escaping (SignInRouter) -> SignInFeature
    ) {
        self.makeSignInFeature = makeSignInFeature
    }

    @MainActor
    public func makeSignInViewController(router: SignInRouter) -> UIViewController {
        let store: StoreOf<SignInFeature> = .init(initialState: SignInFeature.State()) {
            makeSignInFeature(router)
        }
        let view = SignInView(store: store)

        return UIHostingController(rootView: view)
    }
}
