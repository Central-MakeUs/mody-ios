//
//  ModyGroupInterface.swift
//  ModyGroupInterface
//
//  Created by 김동준 on 6/26/26
//

import UIKit

public protocol ModyGroupBuildable {
    @MainActor
    func makeModyGroupViewController(
        entryPoint: ModyGroupEntryPoint,
        showSignUpDoneContents: Bool,
        initialScreen: ModyGroupInitialScreen,
        router: ModyGroupRouter,
        outputHandler: ModyGroupOutputHandler?
    ) -> UIViewController
}
