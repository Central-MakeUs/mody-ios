//
//  MyPageProfileResponse.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import CommonDomain

struct MyPageProfileResponse: Decodable, Equatable {
    let loginType: String?
    let name: String?
    let birthDate: String?
}

extension MyPageProfileResponse {
    func toDomain() -> MyPageProfile {
        MyPageProfile(
            socialLoginType: SocialLoginType(rawValue: loginType ?? "") ?? .kakao,
            name: name ?? "-",
            birthDate: birthDate ?? ""
        )
    }
}
