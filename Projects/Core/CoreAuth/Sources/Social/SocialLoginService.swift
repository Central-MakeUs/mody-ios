//
//  SocialLoginService.swift
//  CoreAuth
//
//  Created by 김동준 on 7/2/26
//

import CoreAuthInterface
import CoreKakaoInterface

public final class SocialLoginService: SocialLoginInterface {
    private let kakaoAuthService: CoreKakaoAuthInterface
    var appleSignDelegate: AppleSignDelegate?

    public init(kakaoAuthService: CoreKakaoAuthInterface) {
        self.kakaoAuthService = kakaoAuthService
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
