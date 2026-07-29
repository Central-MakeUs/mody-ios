//
//  GroupModel.swift
//  CommonDomain
//
//  Created by 김동준 on 7/13/26.
//

public struct GroupModel: Equatable, Sendable {
    public let groupId: Int
    public let name: String
    public let code: String
    public let memberCount: Int

    public init(
        groupId: Int,
        name: String,
        code: String,
        memberCount: Int
    ) {
        self.groupId = groupId
        self.name = name
        self.code = code
        self.memberCount = memberCount
    }
}
