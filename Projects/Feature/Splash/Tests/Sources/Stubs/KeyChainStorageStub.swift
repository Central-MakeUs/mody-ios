//
//  KeyChainStorageStub.swift
//  SplashTests
//
//  Created by 김동준 on 10/4/26.
//

import CoreKeyChainStorageInterface

struct KeyChainStorageStub: CoreKeyChainStorageInterface {
    private let values: [String: Any]

    init(values: [String: Any] = [:]) {
        self.values = values
    }

    func save<T: Encodable>(key: String, value: T) throws {}

    func read<T: Decodable>(key: String) throws -> T {
        guard let value = values[key] as? T else {
            throw SplashTestError.expectedFailure
        }
        return value
    }

    func update<T: Encodable>(key: String, value: T) throws {}
    func delete(key: String) throws {}
}
