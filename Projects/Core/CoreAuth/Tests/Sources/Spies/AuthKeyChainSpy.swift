//  AuthKeyChainSpy.swift
//  CoreAuthTests
//
//  Created by 김동준 on 10/8/26.
//

import CoreKeyChainStorageInterface

final class AuthKeyChainSpy: CoreKeyChainStorageInterface {
    var values: [String: Any] = [:]
    var readError: Error?
    var failingSaveKeys: Set<String> = []
    var failingDeleteKeys: Set<String> = []
    private(set) var savedKeys: [String] = []
    private(set) var readKeys: [String] = []
    private(set) var deletedKeys: [String] = []
    private(set) var updatedKeys: [String] = []

    func save<T: Encodable>(key: String, value: T) throws {
        savedKeys.append(key)
        if failingSaveKeys.contains(key) { throw AuthTestError.expected }
        values[key] = value
    }

    func read<T: Decodable>(key: String) throws -> T {
        readKeys.append(key)
        if let readError { throw readError }
        guard let value = values[key] as? T else { throw KeyChainStorageError.noMatchKeyError }
        return value
    }

    func update<T: Encodable>(key: String, value: T) throws {
        updatedKeys.append(key)
        throw AuthTestError.unexpectedCall
    }

    func delete(key: String) throws {
        deletedKeys.append(key)
        if failingDeleteKeys.contains(key) { throw AuthTestError.expected }
        values.removeValue(forKey: key)
    }
}
