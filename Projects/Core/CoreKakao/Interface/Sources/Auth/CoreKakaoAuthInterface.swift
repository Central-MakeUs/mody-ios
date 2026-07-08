//
//  CoreKakaoAuthInterface.swift
//  CoreKakaoInterface
//
//  Created by 김동준 on 7/7/26
//

public protocol CoreKakaoAuthInterface {
    @MainActor
    func signInWithKakao() async throws -> String
}
