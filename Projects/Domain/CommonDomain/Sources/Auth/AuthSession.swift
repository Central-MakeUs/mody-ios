//
//  AuthSession.swift
//  CommonDomain
//
//  Created by 김동준 on 7/2/26
//

public struct AuthSession: Equatable {
    public let id: Int
    public let accessToken: String
    public let refreshToken: String
    public let personalInfoCompleted: Bool

    public init(
        id: Int,
        accessToken: String,
        refreshToken: String,
        personalInfoCompleted: Bool
    ) {
        self.id = id
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.personalInfoCompleted = personalInfoCompleted
    }
}
