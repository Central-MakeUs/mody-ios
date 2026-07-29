//
//  SocialLoginService+Apple.swift
//  CoreAuth
//
//  Created by 김동준 on 7/2/26
//

import Foundation
import AuthenticationServices

extension SocialLoginService {
    @MainActor
    func loginWithApple() async throws -> String {
        defer { appleSignDelegate = nil }

        return try await withCheckedThrowingContinuation { continuation in
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            appleSignDelegate = AppleSignDelegate(continuation: continuation)
            controller.delegate = appleSignDelegate
            controller.performRequests()
        }
    }
}
