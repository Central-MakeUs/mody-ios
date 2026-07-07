//
//  ShareGroupInviteUseCase.swift
//  ModyGroup
//
//  Created by 김동준 on 7/7/26
//

import CoreKakaoInterface

public struct ShareGroupInviteUseCase: ShareGroupInviteUseCaseProtocol {
    private let kakaoShareService: CoreKakaoShareInterface

    public init(kakaoShareService: CoreKakaoShareInterface) {
        self.kakaoShareService = kakaoShareService
    }

    @MainActor
    public func shareCodeToKakao() async throws {
        try await kakaoShareService.shareCodeToKakao(code: "AABB1122")
    }
}
