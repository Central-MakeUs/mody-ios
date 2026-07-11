//
//  GroupJoinRepositoryProtocol.swift
//  ModyGroup
//
//  Created by 김동준 on 7/10/26
//

public protocol GroupJoinRepositoryProtocol {
    func postJoinGroup(request: GroupJoinRequest) async throws
}
