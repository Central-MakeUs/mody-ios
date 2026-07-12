//
//  MyPageBuilder.swift
//  MyPage
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import SwiftUI
import MyPageInterface
import ComposableArchitecture

public struct MyPageBuilder: MyPageBuildable {
    private let makeMyPageFeature: (MyPageRouter) -> MyPageFeature
    private let makeProfileFeature: (MyPageProfileRouter) -> ProfileFeature

    public init(
        makeMyPageFeature: @escaping (MyPageRouter) -> MyPageFeature,
        makeProfileFeature: @escaping (MyPageProfileRouter) -> ProfileFeature
    ) {
        self.makeMyPageFeature = makeMyPageFeature
        self.makeProfileFeature = makeProfileFeature
    }

    @MainActor
    public func makeMyPageViewController(router: MyPageRouter) -> UIViewController {
        let store: StoreOf<MyPageFeature> = .init(initialState: MyPageFeature.State()) {
            makeMyPageFeature(router)
        }
        let view = MyPageView(store: store)

        return UIHostingController(rootView: view)
    }

    @MainActor
    public func makeProfileViewController(router: MyPageProfileRouter) -> UIViewController {
        let store: StoreOf<ProfileFeature> = .init(initialState: ProfileFeature.State()) {
            makeProfileFeature(router)
        }
        let view = ProfileView(store: store)

        return UIHostingController(rootView: view)
    }
}
