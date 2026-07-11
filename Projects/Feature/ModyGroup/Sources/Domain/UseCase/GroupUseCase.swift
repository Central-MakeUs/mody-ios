//
//  GroupUseCase.swift
//  ModyGroup
//
//  Created by 김동준 on 7/11/26
//

public struct GroupUseCase {
    private let groupRepository: GroupRepositoryProtocol

    public init(groupRepository: GroupRepositoryProtocol) {
        self.groupRepository = groupRepository
    }

    public func createGroup(request: GroupCreateRequest) async throws -> String {
        try await groupRepository.postCreateGroup(request: request)
    }

    public func joinGroup(request: GroupJoinRequest) async throws {
        try await groupRepository.postJoinGroup(request: request)
    }
}
