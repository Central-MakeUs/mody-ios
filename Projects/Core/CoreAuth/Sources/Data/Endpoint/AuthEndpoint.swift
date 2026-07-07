//
//  AuthEndpoint.swift
//  CoreAuth
//
//  Created by 김동준 on 7/2/26
//

import CoreAuthInterface
import CoreNetworkInterface
import CommonDomain

enum AuthEndpoint {
    static func getSignIn(
        loginType: SocialLoginType,
        accessToken: String
    ) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/oauth/client/\(loginType.rawValue)",
            method: .GET,
            queryParameters: ["accessToken": accessToken],
            requiresAuthorization: false
        )
    }

    static func postLogout(refreshToken: String) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/auth/logout",
            method: .POST,
            bodyParameters: ["refreshToken": refreshToken]
        )
    }
}
