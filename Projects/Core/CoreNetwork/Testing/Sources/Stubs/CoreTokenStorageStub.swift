//  CoreTokenStorageStub.swift
//  CoreNetworkTesting
//
//  Created by 김동준 on 10/9/26.
//

import CoreNetworkInterface

public actor CoreTokenStorageStub: CoreTokenStorage {
    private var access: String?
    private var refresh: String?

    public init(accessToken: String? = nil, refreshToken: String? = nil) {
        access = accessToken
        refresh = refreshToken
    }

    public func accessToken() -> String? { access }
    public func refreshToken() -> String? { refresh }

    public func save(accessToken: String, refreshToken: String?) {
        access = accessToken
        if let refreshToken { refresh = refreshToken }
    }
}
