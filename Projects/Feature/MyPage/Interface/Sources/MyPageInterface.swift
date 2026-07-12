//
//  MyPageInterface.swift
//  MyPageInterface
//
//  Created by 김동준 on 6/30/26
//

import UIKit

public protocol MyPageBuildable {
    @MainActor
    func makeMyPageViewController(router: MyPageRouter) -> UIViewController

    @MainActor
    func makeProfileViewController(router: MyPageProfileRouter) -> UIViewController
}
