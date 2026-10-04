//
//  ShareGroupInviteSpy.swift
//  ModyGroupTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
@testable import ModyGroup

@MainActor
final class ShareGroupInviteSpy: ShareGroupInviteUseCaseProtocol {
    var result: Result<Void, Error> = .success(())
    private(set) var requests: [(code: String, groupName: String)] = []

    func shareCodeToKakao(code: String, groupName: String) async throws {
        requests.append((code, groupName))
        try result.get()
    }
}
