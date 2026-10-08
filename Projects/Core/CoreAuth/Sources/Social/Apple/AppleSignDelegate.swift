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

    func completeSignIn(identityToken: Data?) {
        guard let identityToken,
              let token = String(data: identityToken, encoding: .utf8) else {
            continuation?.resume(throwing: CoreAuthErrorModel.unKnownError)
            continuation = nil
            return
        }

        continuation?.resume(returning: token)
        continuation = nil
    }
}

extension AppleSignDelegate: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        let credential = authorization.credential as? ASAuthorizationAppleIDCredential
        completeSignIn(identityToken: credential?.identityToken)
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
