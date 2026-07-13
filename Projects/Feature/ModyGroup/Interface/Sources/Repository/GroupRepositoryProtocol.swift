//
//  GroupRepositoryProtocol.swift
//  ModyGroupInterface
//
//  Created by 김동준 on 7/13/26.
//

import CommonDomain

public protocol GroupRepositoryProtocol {
    func createGroup(name: String) async throws -> String
    func joinGroup(code: String) async throws
    func getGroups() async throws -> [GroupModel]
}
