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

    public init(
        makeMyPageFeature: @escaping (MyPageRouter) -> MyPageFeature
    ) {
        self.makeMyPageFeature = makeMyPageFeature
    }

    @MainActor
    public func makeMyPageViewController(router: MyPageRouter) -> UIViewController {
        let store: StoreOf<MyPageFeature> = .init(initialState: MyPageFeature.State()) {
            makeMyPageFeature(router)
        }
        let view = MyPageView(store: store)

        return UIHostingController(rootView: view)
    }
}
