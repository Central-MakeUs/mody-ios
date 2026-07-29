//
//  CoreTokenStorage.swift
//  CoreNetworkInterface
//
//  Created by 김동준 on 6/30/26
//

public protocol CoreTokenStorage {
    func accessToken() async -> String?
    func refreshToken() async -> String?
    func save(accessToken: String, refreshToken: String?) async
}
