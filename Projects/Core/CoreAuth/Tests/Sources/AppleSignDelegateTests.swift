//  AppleSignDelegateTests.swift
//  CoreAuthTests
//
//  Created by 김동준 on 10/8/26.
//

import AuthenticationServices
import CoreAuthInterface
import XCTest
@testable import CoreAuth

@MainActor
final class AppleSignDelegateTests: XCTestCase {
    func testValidUTF8TokenIsReturnedWithoutModification() async throws {
        for token in ["header.payload.signature", "한글 토큰", ""] {
            let result = try await complete { $0.completeSignIn(identityToken: Data(token.utf8)) }
            XCTAssertEqual(result, token)
        }
    }

    func testMissingIdentityTokenThrowsUnknownError() async {
        await XCTAssertThrowsErrorAsync({ try await self.complete { $0.completeSignIn(identityToken: nil) } }) {
            guard case CoreAuthErrorModel.unKnownError = $0 else { return XCTFail("Unexpected error: \($0)") }
        }
    }

    func testInvalidUTF8TokenThrowsUnknownError() async {
        for bytes: [UInt8] in [[0xFF], [0xC3, 0x28], [0xE2, 0x82]] {
            await XCTAssertThrowsErrorAsync({ try await self.complete { $0.completeSignIn(identityToken: Data(bytes)) } }) {
                guard case CoreAuthErrorModel.unKnownError = $0 else { return XCTFail("Unexpected error: \($0)") }
            }
        }
    }

    func testAppleCancellationAndOtherAuthorizationErrorsAreForwarded() async {
        for code in [ASAuthorizationError.canceled, .failed, .invalidResponse, .notHandled, .unknown] {
            let expected = NSError(domain: ASAuthorizationError.errorDomain, code: code.rawValue)
            await XCTAssertThrowsErrorAsync({
                try await self.complete { delegate in
                    delegate.authorizationController(controller: self.controller(), didCompleteWithError: expected)
                }
            }) { XCTAssertEqual($0 as NSError, expected) }
        }
    }

    func testArbitraryErrorIsForwardedWithoutMapping() async {
        await XCTAssertThrowsErrorAsync({
            try await self.complete { $0.authorizationController(controller: self.controller(), didCompleteWithError: AuthTestError.expected) }
        }) { XCTAssertEqual($0 as? AuthTestError, .expected) }
    }

    func testSuccessIgnoresSubsequentSuccessInvalidTokenAndErrorCallbacks() async throws {
        let result = try await complete { delegate in
            delegate.completeSignIn(identityToken: Data("first".utf8))
            delegate.completeSignIn(identityToken: Data("second".utf8))
            delegate.completeSignIn(identityToken: nil)
            delegate.completeSignIn(identityToken: Data([0xFF]))
            delegate.authorizationController(controller: controller(), didCompleteWithError: AuthTestError.expected)
        }
        XCTAssertEqual(result, "first")
    }

    func testTokenFailureIgnoresSubsequentSuccessAndErrorCallbacks() async {
        for token in [nil, Data([0xFF])] {
            await XCTAssertThrowsErrorAsync({
                try await self.complete { delegate in
                    delegate.completeSignIn(identityToken: token)
                    delegate.completeSignIn(identityToken: Data("later".utf8))
                    delegate.authorizationController(controller: self.controller(), didCompleteWithError: AuthTestError.expected)
                }
            }) {
                guard case CoreAuthErrorModel.unKnownError = $0 else { return XCTFail("Unexpected error: \($0)") }
            }
        }
    }

    func testErrorIgnoresSubsequentErrorAndTokenCallbacks() async {
        await XCTAssertThrowsErrorAsync({
            try await self.complete { delegate in
                delegate.authorizationController(controller: self.controller(), didCompleteWithError: AuthTestError.expected)
                delegate.authorizationController(controller: self.controller(), didCompleteWithError: AuthTestError.unexpectedCall)
                delegate.completeSignIn(identityToken: Data("later".utf8))
                delegate.completeSignIn(identityToken: nil)
            }
        }) { XCTAssertEqual($0 as? AuthTestError, .expected) }
    }

    private func complete(_ callback: (AppleSignDelegate) -> Void) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            callback(AppleSignDelegate(continuation: continuation))
        }
    }

    private func controller() -> ASAuthorizationController {
        ASAuthorizationController(authorizationRequests: [ASAuthorizationAppleIDProvider().createRequest()])
    }
}
