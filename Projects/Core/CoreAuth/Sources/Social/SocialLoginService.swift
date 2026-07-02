//
//  SocialLoginService.swift
//  CoreAuth
//
//  Created by 김동준 on 7/2/26
//

import CoreAuthInterface
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

public final class SocialLoginService: SocialLoginInterface {
    var appleSignDelegate: AppleSignDelegate?

    public init() {}

    @MainActor
    public func signInWithKakao() async throws -> String? {
        do {
            let token: OAuthToken

            if UserApi.isKakaoTalkLoginAvailable() {
                token = try await loginWithKakaoTalk()
            } else {
                token = try await loginWithKakaoAccount()
            }

            return token.accessToken
        } catch let error as SdkError {
            print("TODO: Handle Kakao SDK login error: \(error)")
            throw error
        } catch {
            print("TODO: Handle unknown Kakao login error: \(error)")
            throw error
        }
    }

    @MainActor
    public func signInWithApple() async throws -> String? {
        try await loginWithApple()
    }
}
