//
//  SocialLoginService.swift
//  CoreAuth
//
//  Created by 김동준 on 7/2/26
//

import AuthenticationServices
import CoreAuthInterface
import CoreKakaoInterface

public final class SocialLoginService: SocialLoginInterface {
    private let kakaoAuthService: CoreKakaoAuthInterface
    let performAppleRequest: @MainActor (ASAuthorizationController) -> Void
    var appleSignDelegate: AppleSignDelegate?

    public convenience init(kakaoAuthService: CoreKakaoAuthInterface) {
        self.init(kakaoAuthService: kakaoAuthService) { $0.performRequests() }
    }

    init(
        kakaoAuthService: CoreKakaoAuthInterface,
        performAppleRequest: @escaping @MainActor (ASAuthorizationController) -> Void
    ) {
        self.kakaoAuthService = kakaoAuthService
        self.performAppleRequest = performAppleRequest
    }

    @MainActor
    public func signInWithKakao() async throws -> String? {
        try await kakaoAuthService.signInWithKakao()
    }

    @MainActor
    public func signInWithApple() async throws -> String? {
        try await loginWithApple()
    }
}
