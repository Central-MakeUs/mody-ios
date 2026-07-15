//
//  GroupListResponse.swift
//  ModyGroup
//
//  Created by 김동준 on 7/13/26.
//

import CommonDomain

struct GroupListResponse: Decodable, Equatable {
    let groups: [GroupItemResponse]?
}

struct GroupItemResponse: Decodable, Equatable {
    let groupId: Int?
    let name: String?
    let code: String?
    let memberCount: Int?
}

extension GroupListResponse {
    func toDomain() -> [GroupModel] {
        (groups ?? []).map { group in
            GroupModel(
                groupId: group.groupId ?? -1,
                name: group.name ?? "",
                code: group.code ?? "",
                memberCount: group.memberCount ?? 0
            )
        }
    }
}
