//
//  SplashEndpoint.swift
//  Splash
//
//  Created by 김동준 on 7/7/26
//

import CoreNetworkInterface

enum SplashEndpoint {
    static func getHealthCheck() -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "health",
            method: .GET,
            requiresAuthorization: false
        )
    }
}
