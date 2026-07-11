//
//  GroupRepositoryProtocol.swift
//  ModyGroup
//
//  Created by 김동준 on 7/11/26
//

public protocol GroupRepositoryProtocol {
    func postCreateGroup(request: GroupCreateRequest) async throws -> String
    func postJoinGroup(request: GroupJoinRequest) async throws
}
