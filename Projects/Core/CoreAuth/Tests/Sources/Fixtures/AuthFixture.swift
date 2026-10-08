//  AuthFixture.swift
//  CoreAuthTests
//
//  Created by 김동준 on 10/8/26.
//

import CommonDomain

enum AuthFixture {
    static let loginTypes: [SocialLoginType] = [.kakao, .apple, .iosTest]
    static let session = AuthSession(
        id: 42, accessToken: "server-access", refreshToken: "server-refresh",
        personalInfoCompleted: true, mainAccessible: false, groupOnboardingCompleted: true
    )
    static let user = UserInfo(
        memberId: 42, nickname: "모디", profileImageUrl: "https://example.com/profile.png",
        daysTogether: 17, personalInfoCompleted: true,
        groupOnboardingCompleted: false, mainAccessible: true
    )
    static let sessionJSON = """
    {"id":42,"accessToken":"server-access","refreshToken":"server-refresh",
     "personalInfoCompleted":true,"mainAccessible":false,"groupOnboardingCompleted":true}
    """
    static let userJSON = """
    {"memberId":42,"nickname":"모디","profileImageUrl":"https://example.com/profile.png",
     "daysTogether":17,"personalInfoCompleted":true,"groupOnboardingCompleted":false,"mainAccessible":true}
    """

    static func response(_ result: String) -> String {
        "{\"isSuccess\":true,\"code\":\"SUCCESS\",\"result\":\(result)}"
    }
}

enum AuthTestError: Error, Equatable {
    case expected
    case unexpectedCall
}
