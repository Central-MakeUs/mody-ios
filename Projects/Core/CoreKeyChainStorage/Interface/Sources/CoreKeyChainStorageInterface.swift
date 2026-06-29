//
//  CoreKeyChainStorageInterface.swift
//  CoreKeyChainStorageInterface
//
//  Created by 김동준 on 6/29/26
//

import Foundation

public protocol CoreKeyChainStorageInterface {
    func save<T: Encodable>(key: String, value: T) throws
    func read<T: Decodable>(key: String) throws -> T
    func update<T: Encodable>(key: String, value: T) throws
    func delete(key: String) throws
}
