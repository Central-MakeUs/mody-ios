//
//  AppleSignDelegate.swift
//  CoreAuth
//
//  Created by 김동준 on 7/2/26
//

import AuthenticationServices
import CoreAuthInterface
import Foundation

final class AppleSignDelegate: NSObject {
    private var continuation: CheckedContinuation<String, Error>?

    init(continuation: CheckedContinuation<String, Error>) {
        self.continuation = continuation
    }
}

extension AppleSignDelegate: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityToken = credential.identityToken,
            let token = String(data: identityToken, encoding: .utf8)
        else {
            continuation?.resume(throwing: CoreAuthErrorModel.unKnownError)
            continuation = nil
            return
        }

        continuation?.resume(returning: token)
        continuation = nil
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
