//
//  GroupJoinResponse.swift
//  ModyGroup
//
//  Created by 김동준 on 7/10/26
//

struct GroupJoinResponse: Decodable, Equatable {
    let groupId: Int?
    let code: String?
    let name: String?
    let memberCount: Int?
}
