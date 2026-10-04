//
//  SignInRepositoryTests.swift
//  SignInTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import XCTest
@testable import SignIn

final class SignInRepositoryTests: XCTestCase {
    func testReadsGuestLoginRemoteConfigFlag() {
        for isEnabled in [false, true] {
            let firebase = FirebaseServiceSpy(isEnabled: isEnabled)
            let repository = SignInRepository(firebaseService: firebase)

            XCTAssertEqual(repository.isDemoLoginEnabled(), isEnabled)
            XCTAssertEqual(firebase.requestedKeys, [RemoteConfigKeys.guestLogin.rawValue])
        }
    }
}
