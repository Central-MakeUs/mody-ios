//  FirebaseServiceStub.swift
//  FirebaseServiceTesting
//
//  Created by 김동준 on 10/9/26.
//

import FirebaseServiceInterface

public struct FirebaseServiceStub: FirebaseServiceInterface {
    private let strings: [String: String]
    private let bools: [String: Bool]
    private let jsonValues: [String: any Decodable]
    private let fetch: () async throws -> Void

    public init(
        strings: [String: String] = [:],
        bools: [String: Bool] = [:],
        jsonValues: [String: any Decodable] = [:],
        fetchAndActivate: @escaping () async throws -> Void = {}
    ) {
        self.strings = strings
        self.bools = bools
        self.jsonValues = jsonValues
        self.fetch = fetchAndActivate
    }

    public func fetchAndActivate() async throws {
        try await fetch()
    }

    public func getString(forKey key: String) -> String {
        strings[key, default: ""]
    }

    public func getBool(forKey key: String) -> Bool {
        bools[key, default: false]
    }

    public func getJson<Value: Decodable>(forKey key: String, as type: Value.Type) -> Value? {
        jsonValues[key] as? Value
    }
}
