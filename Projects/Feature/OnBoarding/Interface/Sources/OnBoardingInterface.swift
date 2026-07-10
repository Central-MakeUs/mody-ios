//
//  OnBoardingInterface.swift
//  OnBoardingInterface
//
//  Created by 김동준 on 6/25/26
//

import UIKit

public protocol OnBoardingBuildable {
    @MainActor
    func makeOnBoardingViewController(router: OnBoardingRouter) -> UIViewController
}
