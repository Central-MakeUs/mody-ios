//
//  SignInRepositoryStub.swift
//  SignInTests
//
//  Created by 김동준 on 10/4/26.
//

@testable import SignIn

struct SignInRepositoryStub: SignInRepositoryProtocol {
    let isEnabled: Bool

    func isDemoLoginEnabled() -> Bool {
        isEnabled
    }
}
