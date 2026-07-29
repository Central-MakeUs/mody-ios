//
//  GroupCreateResponse.swift
//  ModyGroup
//
//  Created by 김동준 on 7/11/26
//

struct GroupCreateResponse: Decodable, Equatable {
    let groupId: Int?
    let code: String?
    let name: String?
}
