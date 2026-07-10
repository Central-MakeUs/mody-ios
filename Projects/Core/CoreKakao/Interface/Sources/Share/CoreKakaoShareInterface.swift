//
//  CoreKakaoShareInterface.swift
//  CoreKakaoInterface
//
//  Created by 김동준 on 7/7/26
//

public protocol CoreKakaoShareInterface {
    @MainActor
    func shareCodeToKakao(code: String) async throws
}
