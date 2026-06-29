//
//  KeyChainStorageError.swift
//  CoreKeyChainStorageInterface
//
//  Created by 김동준 on 6/29/26
//

import Foundation

public enum KeyChainStorageError: Error {
    case unExpectedStatus(OSStatus)
    case encodingFailed
    case decodingFailed
    case noMatchKeyError
    
    public var description: String {
        switch self {
        case .encodingFailed:
            """
            🛑 KeyChainStorageError: Encoding failed
            """
        case .decodingFailed:
            """
            🛑 KeyChainStorageError: Decoding failed
            """
        case .noMatchKeyError:
            """
            🛑 KeyChainStorageError: No Match Key Error
            """
        case .unExpectedStatus(let status):
            """
            🛑 KeyChainStorageError: UnExpectedStatus
              - 타입: \(type(of: status))
              - 설명: \(status.description)
            """
        }
    }
}
