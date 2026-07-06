//
//  ModyGroupBuilder.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import UIKit
import SwiftUI
import ModyGroupInterface
import ComposableArchitecture

public struct ModyGroupBuilder: ModyGroupBuildable {
    private let makeModyGroupRootFeature: (ModyGroupRouter) -> ModyGroupRootFeature

    public init(
        makeModyGroupRootFeature: @escaping (ModyGroupRouter) -> ModyGroupRootFeature
    ) {
        self.makeModyGroupRootFeature = makeModyGroupRootFeature
    }

    @MainActor
    public func makeModyGroupViewController(router: ModyGroupRouter) -> UIViewController {
        let view = ModyGroupRootView(
            store: .init(initialState: .init()) {
                makeModyGroupRootFeature(router)
            }
        )

        return UIHostingController(rootView: view)
    }
}
