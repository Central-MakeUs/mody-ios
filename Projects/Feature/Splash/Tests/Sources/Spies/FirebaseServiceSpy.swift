//
//  FirebaseServiceSpy.swift
//  SplashTests
//
//  Created by 김동준 on 10/4/26.
//

import FirebaseServiceInterface

final class FirebaseServiceSpy: FirebaseServiceInterface {
    private let fetchError: Error?
    private let strings: [String: String]
    private let bools: [String: Bool]
    private let jsonValues: [String: Any]

    private(set) var fetchAndActivateCallCount = 0

    init(
        fetchError: Error? = nil,
        strings: [String: String] = [:],
        bools: [String: Bool] = [:],
        jsonValues: [String: Any] = [:]
    ) {
        self.fetchError = fetchError
        self.strings = strings
        self.bools = bools
        self.jsonValues = jsonValues
    }

    func fetchAndActivate() async throws {
        fetchAndActivateCallCount += 1
        if let fetchError {
            throw fetchError
        }
    }

    func getString(forKey key: String) -> String {
        strings[key, default: ""]
    }

    func getBool(forKey key: String) -> Bool {
        bools[key, default: false]
    }

    func getJson<Value: Decodable>(
        forKey key: String,
        as type: Value.Type
    ) -> Value? {
        jsonValues[key] as? Value
    }
}
