//
//  SplashInterface.swift
//  SplashInterface
//
//  Created by 김동준 on 6/25/26
//

import UIKit

public protocol SplashBuildable {
    @MainActor
    func makeSplashViewController(router: SplashRouter) -> UIViewController
}
