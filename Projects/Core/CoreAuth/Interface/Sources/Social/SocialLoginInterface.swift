//
//  SocialLoginInterface.swift
//  CoreAuthInterface
//
//  Created by 김동준 on 7/2/26
//

public protocol SocialLoginInterface {
    @MainActor
    func signInWithKakao() async throws -> String?
    
    @MainActor
    func signInWithApple() async throws -> String?
}
