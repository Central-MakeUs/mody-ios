//
//  GroupEndpoint.swift
//  ModyGroup
//
//  Created by 김동준 on 7/11/26
//

import CoreNetworkInterface

enum GroupEndpoint {
    static func postCreate(request: GroupCreateRequest) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/groups",
            method: .POST,
            bodyParameters: request
        )
    }

    static func postJoin(request: GroupJoinRequest) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/groups/join",
            method: .POST,
            bodyParameters: request
        )
    }
}
