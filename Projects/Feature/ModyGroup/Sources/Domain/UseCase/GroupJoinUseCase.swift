//
//  GroupJoinUseCase.swift
//  ModyGroup
//
//  Created by 김동준 on 7/10/26
//

public struct GroupJoinUseCase {
    private let groupJoinRepository: GroupJoinRepositoryProtocol

    public init(groupJoinRepository: GroupJoinRepositoryProtocol) {
        self.groupJoinRepository = groupJoinRepository
    }

    public func joinGroup(request: GroupJoinRequest) async throws {
        try await groupJoinRepository.postJoinGroup(request: request)
    }
}
