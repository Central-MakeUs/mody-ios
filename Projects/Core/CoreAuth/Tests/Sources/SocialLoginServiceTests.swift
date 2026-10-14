//  SocialLoginServiceTests.swift
//  CoreAuthTests
//
//  Created by 김동준 on 10/8/26.
//

import AuthenticationServices
import CoreAuthInterface
import XCTest
@testable import CoreAuth

final class SocialLoginServiceTests: XCTestCase {
    @MainActor
    func testKakaoReturnsTokenIncludingEmptyStringAndCallsProviderOnce() async throws {
        for token in ["kakao-token", "", "한글 +/&?=token"] {
            let kakao = KakaoAuthSpy()
            kakao.result = .success(token)
            let sut = SocialLoginService(kakaoAuthService: kakao)

            let result = try await sut.signInWithKakao()

            XCTAssertEqual(result, token)
            XCTAssertEqual(kakao.signInCount, 1)
            XCTAssertNil(sut.appleSignDelegate)
        }
    }

    @MainActor
    func testKakaoPropagatesProviderErrorAndCancellation() async {
        for error in [AuthTestError.expected as Error, CancellationError()] {
            let kakao = KakaoAuthSpy()
            kakao.result = .failure(error)
            let sut = SocialLoginService(kakaoAuthService: kakao)
            await XCTAssertThrowsErrorAsync({ try await sut.signInWithKakao() }) {
                XCTAssertEqual($0 as NSError, error as NSError)
            }
            XCTAssertEqual(kakao.signInCount, 1)
            XCTAssertNil(sut.appleSignDelegate)
        }
    }

    @MainActor
    func testAppleRequestsNameAndEmailReturnsTokenAndReleasesDelegateAfterSuccess() async throws {
        let kakao = KakaoAuthSpy()
        var requestCount = 0
        weak var observedDelegate: AppleSignDelegate?
        let sut = SocialLoginService(kakaoAuthService: kakao) { controller in
            requestCount += 1
            XCTAssertEqual(controller.authorizationRequests.count, 1)
            let request = controller.authorizationRequests.first as? ASAuthorizationAppleIDRequest
            XCTAssertEqual(request?.requestedScopes, [.fullName, .email])
            observedDelegate = controller.delegate as? AppleSignDelegate
            XCTAssertNotNil(observedDelegate)
            observedDelegate?.completeSignIn(identityToken: Data("apple-token".utf8))
        }

        let result = try await sut.signInWithApple()

        XCTAssertEqual(result, "apple-token")
        XCTAssertEqual(requestCount, 1)
        XCTAssertEqual(kakao.signInCount, 0)
        XCTAssertNil(sut.appleSignDelegate)
        XCTAssertNil(observedDelegate)
    }

    @MainActor
    func testAppleAuthorizationFailureAndCancellationReleaseDelegateAndPermitRetry() async throws {
        let kakao = KakaoAuthSpy()
        for error in [
            NSError(domain: ASAuthorizationError.errorDomain, code: ASAuthorizationError.canceled.rawValue),
            NSError(domain: ASAuthorizationError.errorDomain, code: ASAuthorizationError.failed.rawValue)
        ] {
            var requestCount = 0
            let sut = SocialLoginService(kakaoAuthService: kakao) { controller in
                requestCount += 1
                if requestCount == 1 {
                    controller.delegate?.authorizationController?(controller: controller, didCompleteWithError: error)
                } else {
                    (controller.delegate as? AppleSignDelegate)?.completeSignIn(identityToken: Data("retry-token".utf8))
                }
            }

            await XCTAssertThrowsErrorAsync({ try await sut.signInWithApple() }) {
                XCTAssertEqual($0 as NSError, error)
            }
            XCTAssertNil(sut.appleSignDelegate)
            let retry = try await sut.signInWithApple()
            XCTAssertEqual(retry, "retry-token")
            XCTAssertEqual(requestCount, 2)
            XCTAssertNil(sut.appleSignDelegate)
        }
        XCTAssertEqual(kakao.signInCount, 0)
    }

    @MainActor
    func testAppleMissingAndInvalidIdentityTokensReleaseDelegate() async {
        for token in [nil, Data([0xFF])] {
            let kakao = KakaoAuthSpy()
            let sut = SocialLoginService(kakaoAuthService: kakao) { controller in
                (controller.delegate as? AppleSignDelegate)?.completeSignIn(identityToken: token)
            }
            await XCTAssertThrowsErrorAsync({ try await sut.signInWithApple() }) {
                guard case CoreAuthErrorModel.unKnownError = $0 else { return XCTFail("Unexpected error: \($0)") }
            }
            XCTAssertNil(sut.appleSignDelegate)
            XCTAssertEqual(kakao.signInCount, 0)
        }
    }
}
