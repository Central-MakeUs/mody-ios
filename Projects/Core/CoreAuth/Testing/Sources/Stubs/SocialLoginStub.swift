//
//  SocialLoginStub.swift
//  CoreAuthTesting
//
//  Created by 김동준 on 10/8/26.
//

import CoreAuthInterface

public struct SocialLoginStub: SocialLoginInterface {
    private let result: Result<String?, Error>
    private let responseDelay: Duration

    public init(result: Result<String?, Error>, responseDelay: Duration = .zero) {
        self.result = result
        self.responseDelay = responseDelay
    }

    @MainActor
    public func signInWithKakao() async throws -> String? {
        try await socialLoginResult()
    }

    @MainActor
    public func signInWithApple() async throws -> String? {
        try await socialLoginResult()
    }

    private func socialLoginResult() async throws -> String? {
        if responseDelay > .zero {
            try await Task.sleep(for: responseDelay)
        }
        return try result.get()
    }
}
