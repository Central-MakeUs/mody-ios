//
//  GroupCreateRequest.swift
//  ModyGroup
//
//  Created by 김동준 on 7/11/26
//

public struct GroupCreateRequest: Encodable, Equatable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}
