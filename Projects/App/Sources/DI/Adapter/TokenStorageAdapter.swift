//
//  TokenStorageAdapter.swift
//  Mody
//
//  Created by 김동준 on 7/2/26
//

import CoreKeyChainStorageInterface
import CoreNetworkInterface

final class TokenStorageAdapter: CoreTokenStorage {
    private let keyChainStorage: CoreKeyChainStorageInterface

    init(keyChainStorage: CoreKeyChainStorageInterface) {
        self.keyChainStorage = keyChainStorage
    }

    func accessToken() async -> String? {
        try? keyChainStorage.read(key: KeyChainStorageKey.accessToken.rawValue)
    }

    func refreshToken() async -> String? {
        try? keyChainStorage.read(key: KeyChainStorageKey.refreshToken.rawValue)
    }

    func save(accessToken: String, refreshToken: String?) async {
        try? keyChainStorage.save(
            key: KeyChainStorageKey.accessToken.rawValue,
            value: accessToken
        )

        guard let refreshToken else { return }
        try? keyChainStorage.save(
            key: KeyChainStorageKey.refreshToken.rawValue,
            value: refreshToken
        )
    }
}
