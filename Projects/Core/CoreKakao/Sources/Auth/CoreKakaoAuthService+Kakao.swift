//
//  CoreKakaoAuthService+Kakao.swift
//  CoreKakao
//
//  Created by 김동준 on 7/7/26
//

import KakaoSDKAuth
import KakaoSDKUser

extension CoreKakaoAuthService {
    @MainActor
    func loginWithKakaoTalk() async throws -> OAuthToken {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let oauthToken {
                    continuation.resume(returning: oauthToken)
                } else if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: CoreKakaoAuthError.unknown)
                }
            }
        }
    }

    @MainActor
    func loginWithKakaoAccount() async throws -> OAuthToken {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                if let oauthToken {
                    continuation.resume(returning: oauthToken)
                } else if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: CoreKakaoAuthError.unknown)
                }
            }
        }
    }
}

private enum CoreKakaoAuthError: Error {
    case unknown
}
