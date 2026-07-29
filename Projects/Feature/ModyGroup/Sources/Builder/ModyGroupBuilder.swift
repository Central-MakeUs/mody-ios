//
//  ModyGroupBuilder.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import UIKit
import SwiftUI
import Base
import ModyGroupInterface
import ComposableArchitecture

public struct ModyGroupBuilder: ModyGroupBuildable {
    private let makeModyGroupRootFeature: (ModyGroupRouter, ModyGroupOutputHandler?) -> ModyGroupRootFeature

    public init(
        makeModyGroupRootFeature: @escaping (ModyGroupRouter, ModyGroupOutputHandler?) -> ModyGroupRootFeature
    ) {
        self.makeModyGroupRootFeature = makeModyGroupRootFeature
    }

    @MainActor
    public func makeModyGroupViewController(
        entryPoint: ModyGroupEntryPoint,
        showSignUpDoneContents: Bool,
        initialScreen: ModyGroupInitialScreen,
        router: ModyGroupRouter,
        outputHandler: ModyGroupOutputHandler?
    ) -> UIViewController {
        let view = ModyGroupRootView(
            store: .init(
                initialState: .init(
                    entryPoint: entryPoint,
                    showSignUpDoneContents: showSignUpDoneContents,
                    initialScreen: initialScreen
                )
            ) {
                makeModyGroupRootFeature(router, outputHandler)
            }
        )

        let viewController = UIHostingController(rootView: view)
        viewController.isSwipeBackEnabled = false
        return viewController
    }
}
