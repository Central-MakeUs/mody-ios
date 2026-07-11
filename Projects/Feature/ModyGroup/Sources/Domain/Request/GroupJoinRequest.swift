//
//  GroupJoinRequest.swift
//  ModyGroup
//
//  Created by 김동준 on 7/10/26
//

public struct GroupJoinRequest: Encodable, Equatable {
    public let code: String

    public init(code: String) {
        self.code = code
    }
}
