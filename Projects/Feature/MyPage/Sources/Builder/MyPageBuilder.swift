//
//  MyPageBuilder.swift
//  MyPage
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import SwiftUI
import MyPageInterface

public struct MyPageBuilder: MyPageBuildable {
    public init() {}

    @MainActor
    public func makeMyPageViewController(router: MyPageRouter) -> UIViewController {
        let view = MyPageView { [weak router] route in
            router?.route(from: route)
        }

        return UIHostingController(rootView: view)
    }
}
