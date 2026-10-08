//  KakaoAuthSpy.swift
//  CoreAuthTests
//
//  Created by 김동준 on 10/8/26.
//

import CoreKakaoInterface

final class KakaoAuthSpy: CoreKakaoAuthInterface {
    var result: Result<String, Error> = .success("kakao-token")
    private(set) var signInCount = 0

    @MainActor
    func signInWithKakao() async throws -> String {
        signInCount += 1
        return try result.get()
    }
}
