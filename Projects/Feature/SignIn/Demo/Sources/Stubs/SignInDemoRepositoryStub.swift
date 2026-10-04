//
//  SignInDemoRepositoryStub.swift
//  SignInDemo
//
//  Created by 김동준 on 10/1/26.
//

import SignIn

struct SignInDemoRepositoryStub: SignInRepositoryProtocol {
    private let isDemoLoginEnabledValue: Bool

    init(isDemoLoginEnabled: Bool) {
        self.isDemoLoginEnabledValue = isDemoLoginEnabled
    }

    func isDemoLoginEnabled() -> Bool {
        isDemoLoginEnabledValue
    }
}
