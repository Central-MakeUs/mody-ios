//
//  ShareGroupInviteUseCaseProtocol.swift
//  ModyGroup
//
//  Created by 김동준 on 7/7/26
//

public protocol ShareGroupInviteUseCaseProtocol {
    @MainActor
    func shareCodeToKakao(code: String) async throws
}
