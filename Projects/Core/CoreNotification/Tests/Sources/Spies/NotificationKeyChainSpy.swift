//  NotificationKeyChainSpy.swift
//  CoreNotificationTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreKeyChainStorageInterface

final class NotificationKeyChainSpy: CoreKeyChainStorageInterface {
    var token: String?
    var readError: Error?
    var saveError: Error?
    private(set) var readKeys: [String] = []
    private(set) var savedTokens: [(key: String, value: String)] = []

    func read<T: Decodable>(key: String) throws -> T {
        readKeys.append(key)
        if let readError { throw readError }
        guard let value = token as? T else { throw KeyChainStorageError.noMatchKeyError }
        return value
    }

    func save<T: Encodable>(key: String, value: T) throws {
        guard let value = value as? String else { throw NotificationTestError.unexpectedCall }
        savedTokens.append((key, value))
        if let saveError { throw saveError }
        token = value
    }

    func update<T: Encodable>(key: String, value: T) throws {
        throw NotificationTestError.unexpectedCall
    }

    func delete(key: String) throws {
        throw NotificationTestError.unexpectedCall
    }
}
