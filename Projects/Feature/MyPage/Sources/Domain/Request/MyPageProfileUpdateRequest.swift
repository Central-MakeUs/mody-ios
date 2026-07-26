//
//  MyPageProfileUpdateRequest.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

public struct MyPageProfileUpdateRequest: Encodable, Equatable {
    public let nickname: String
    public let birthDate: String
    public let imageKey: String?

    public init(
        nickname: String,
        birthDate: String,
        imageKey: String? = nil
    ) {
        self.nickname = nickname
        self.birthDate = birthDate
        self.imageKey = imageKey
    }
}
