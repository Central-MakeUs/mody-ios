//
//  FirebaseServiceSpy.swift
//  SplashTests
//
//  Created by 김동준 on 10/4/26.
//

import FirebaseServiceInterface
import FirebaseServiceTesting

final class FirebaseServiceSpy: FirebaseServiceInterface {
    private let stub: FirebaseServiceStub

    private(set) var fetchAndActivateCallCount = 0

    init(
        fetchError: Error? = nil,
        strings: [String: String] = [:],
        bools: [String: Bool] = [:],
        jsonValues: [String: any Decodable] = [:]
    ) {
        self.stub = FirebaseServiceStub(
            strings: strings,
            bools: bools,
            jsonValues: jsonValues,
            fetchAndActivate: {
                if let fetchError { throw fetchError }
            }
        )
    }

    func fetchAndActivate() async throws {
        fetchAndActivateCallCount += 1
        try await stub.fetchAndActivate()
    }

    func getString(forKey key: String) -> String {
        stub.getString(forKey: key)
    }

    func getBool(forKey key: String) -> Bool {
        stub.getBool(forKey: key)
    }

    func getJson<Value: Decodable>(
        forKey key: String,
        as type: Value.Type
    ) -> Value? {
        stub.getJson(forKey: key, as: type)
    }
}
