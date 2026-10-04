//
//  SignInRepositoryTests.swift
//  SignInTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import FirebaseServiceInterface
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

private final class FirebaseServiceSpy: FirebaseServiceInterface {
    private let isEnabled: Bool
    private(set) var requestedKeys: [String] = []

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    func fetchAndActivate() async throws {}

    func getString(forKey key: String) -> String { "" }

    func getBool(forKey key: String) -> Bool {
        requestedKeys.append(key)
        return isEnabled
    }

    func getJson<Value: Decodable>(forKey key: String, as type: Value.Type) -> Value? {
        nil
    }
}
