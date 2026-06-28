//
//  SignUpDoneInterface.swift
//  SignUpDoneInterface
//
//  Created by 김동준 on 6/26/26
//

import UIKit

public protocol SignUpDoneBuildable {
    @MainActor
    func makeSignUpDoneViewController(router: SignUpDoneRouter) -> UIViewController
}
