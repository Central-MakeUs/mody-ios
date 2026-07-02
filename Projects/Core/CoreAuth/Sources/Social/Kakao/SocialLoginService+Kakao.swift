//
//  SocialLoginService+Kakao.swift
//  CoreAuth
//
//  Created by 김동준 on 7/2/26
//

import KakaoSDKAuth
import KakaoSDKUser
import CoreAuthInterface

extension SocialLoginService {
    @MainActor
    func loginWithKakaoTalk() async throws -> OAuthToken {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let oauthToken {
                    continuation.resume(returning: oauthToken)
                } else {
                    continuation.resume(throwing: CoreAuthErrorModel.unKnownError)
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
                    continuation.resume(throwing: CoreAuthErrorModel.unKnownError)
                }
            }
        }
    }
}
