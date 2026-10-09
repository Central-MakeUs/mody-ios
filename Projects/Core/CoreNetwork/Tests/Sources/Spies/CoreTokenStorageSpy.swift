//  CoreTokenStorageSpy.swift
//  CoreNetworkTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreNetworkInterface

actor CoreTokenStorageSpy: CoreTokenStorage {
    private var access: String?
    private var refresh: String?
    private(set) var savedTokens: [(String, String?)] = []

    init(access: String? = "old-access", refresh: String? = "old-refresh") {
        self.access = access
        self.refresh = refresh
    }

    func accessToken() -> String? { access }
    func refreshToken() -> String? { refresh }
    func save(accessToken: String, refreshToken: String?) {
        savedTokens.append((accessToken, refreshToken))
        access = accessToken
        if let refreshToken { refresh = refreshToken }
    }
}
