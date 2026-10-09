//  CoreTokenStorageSpy.swift
//  CoreNetworkTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreNetworkInterface
import CoreNetworkTesting

actor CoreTokenStorageSpy: CoreTokenStorage {
    private let storage: CoreTokenStorageStub
    private(set) var savedTokens: [(String, String?)] = []

    init(access: String? = "old-access", refresh: String? = "old-refresh") {
        storage = CoreTokenStorageStub(accessToken: access, refreshToken: refresh)
    }

    func accessToken() async -> String? { await storage.accessToken() }
    func refreshToken() async -> String? { await storage.refreshToken() }
    func save(accessToken: String, refreshToken: String?) async {
        savedTokens.append((accessToken, refreshToken))
        await storage.save(accessToken: accessToken, refreshToken: refreshToken)
    }
}
