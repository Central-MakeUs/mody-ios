//
//  CoreKeyChainStorage.swift
//  CoreKeyChainStorage
//
//  Created by 김동준 on 6/29/26
//

import Foundation
import Security
import CoreKeyChainStorageInterface

public struct CoreKeyChainStorage: CoreKeyChainStorageInterface {
    public init() {}
    
    public func save<T: Encodable>(key: String, value: T) throws {
        let data: Data
        do {
            data = try JSONEncoder().encode(value)
        } catch {
            let error = KeyChainStorageError.encodingFailed
            throw error
        }

        var query = baseQuery(key)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            try update(key: key, value: value)
        default:
            throw KeyChainStorageError.unExpectedStatus(status)
        }
    }
    
    public func read<T: Decodable>(key: String) throws -> T {
        var query = baseQuery(key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var dataTypeRef: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                let error = KeyChainStorageError.noMatchKeyError
                throw error
            }
            
            let error = KeyChainStorageError.unExpectedStatus(status)
            throw error
        }
        
        guard let retrievedData = dataTypeRef as? Data else {
            let error = KeyChainStorageError.decodingFailed
            throw error
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: retrievedData)
        } catch {
            let error = KeyChainStorageError.decodingFailed
            throw error
        }
    }
    
    public func update<T: Encodable>(key: String, value: T) throws {
        let data: Data
        do {
            data = try JSONEncoder().encode(value)
        } catch {
            let error = KeyChainStorageError.encodingFailed
            throw error
        }
        
        let attributes = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ] as [String: Any]
        
        let status = SecItemUpdate(baseQuery(key) as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else {
            throw KeyChainStorageError.unExpectedStatus(status)
        }
    }
    
    public func delete(key: String) throws {
        let query = baseQuery(key)
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
        case errSecSuccess, errSecItemNotFound:
            return
        default:
            throw KeyChainStorageError.unExpectedStatus(status)
        }
    }
}

private extension CoreKeyChainStorage {
    func baseQuery(_ key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
    }
}
