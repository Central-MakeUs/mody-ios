//
//  GroupJoinEndpoint.swift
//  ModyGroup
//
//  Created by 김동준 on 7/10/26
//

import CoreNetworkInterface

enum GroupJoinEndpoint {
    static func postJoin(request: GroupJoinRequest) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/groups/join",
            method: .POST,
            bodyParameters: request
        )
    }
}
