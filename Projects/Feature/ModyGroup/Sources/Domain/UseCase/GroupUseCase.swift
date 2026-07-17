//
//  GroupUseCase.swift
//  ModyGroup
//
//  Created by 김동준 on 7/11/26
//

import CommonDomain
import ModyGroupInterface

public struct GroupUseCase: GroupUseCaseProtocol {
    private let groupRepository: GroupRepositoryProtocol

    public init(groupRepository: GroupRepositoryProtocol) {
        self.groupRepository = groupRepository
    }

    public func createGroup(name: String) async throws -> String {
        try await groupRepository.createGroup(name: name)
    }

    public func joinGroup(code: String) async throws {
        try await groupRepository.joinGroup(code: code)
    }

    public func getGroups() async throws -> [GroupModel] {
        try await groupRepository.getGroups()
    }
}
