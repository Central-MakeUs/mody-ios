//
//  FirebaseServiceSpy.swift
//  SignInTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import FirebaseServiceInterface
import FirebaseServiceTesting

final class FirebaseServiceSpy: FirebaseServiceInterface {
    private let stub: FirebaseServiceStub
    private(set) var requestedKeys: [String] = []

    init(isEnabled: Bool) {
        self.stub = FirebaseServiceStub(bools: [RemoteConfigKeys.guestLogin.rawValue: isEnabled])
    }

    func fetchAndActivate() async throws {
        try await stub.fetchAndActivate()
    }

    func getString(forKey key: String) -> String {
        stub.getString(forKey: key)
    }

    func getBool(forKey key: String) -> Bool {
        requestedKeys.append(key)
        return stub.getBool(forKey: key)
    }

    func getJson<Value: Decodable>(forKey key: String, as type: Value.Type) -> Value? {
        stub.getJson(forKey: key, as: type)
    }
}
