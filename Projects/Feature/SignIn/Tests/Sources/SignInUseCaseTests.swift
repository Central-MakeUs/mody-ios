//
//  SignInUseCaseTests.swift
//  SignInTests
//
//  Created by 김동준 on 10/4/26.
//

import XCTest
@testable import SignIn

final class SignInUseCaseTests: XCTestCase {
    func testDemoLoginAvailabilityFollowsRepository() {
        for isEnabled in [false, true] {
            let useCase = SignInUseCase(
                signInRepository: SignInRepositoryStub(isEnabled: isEnabled)
            )

            XCTAssertEqual(useCase.isDemoLoginEnabled(), isEnabled)
        }
    }
}
