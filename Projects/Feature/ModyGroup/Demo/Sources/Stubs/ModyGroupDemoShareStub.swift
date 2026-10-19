//
//  ModyGroupDemoShareStub.swift
//  ModyGroupDemo
//
//  Created by 김동준 on 10/4/26.
//

import ModyGroup

struct ModyGroupDemoShareStub: ShareGroupInviteUseCaseProtocol {
    private let result: Result<Void, Error>

    init(result: Result<Void, Error>) {
        self.result = result
    }

    @MainActor
    func shareCodeToKakao(code: String, groupName: String) async throws {
        try await Task.sleep(for: .milliseconds(500))
        try result.get()
    }
}
