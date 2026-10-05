//
//  MyPageDemoAuthStub.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import CoreAuthInterface

struct MyPageDemoAuthStub: AuthUseCaseProtocol {
    private let scenario: MyPageScenario
    private let profileData: MyPageDemoProfileData

    init(scenario: MyPageScenario, profileData: MyPageDemoProfileData) {
        self.scenario = scenario
        self.profileData = profileData
    }

    func signIn(loginType: SocialLoginType, accessToken: String) async throws -> AuthSession {
        throw CancellationError()
    }

    func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        if scenario == .userLookupFailure {
            throw NetworkError.networkUnavailable
        }
        return UserInfo(
            memberId: 1,
            nickname: await profileData.name,
            profileImageUrl: nil,
            daysTogether: 20,
            personalInfoCompleted: true,
            groupOnboardingCompleted: true,
            mainAccessible: true
        )
    }

    func logout() async throws {
        if scenario == .logoutFailure {
            throw NetworkError.networkUnavailable
        }
    }

    func deleteAccount() async throws {
        if scenario == .deleteFailure {
            throw NetworkError.networkUnavailable
        }
    }
}
