//
//  SignInScenario.swift
//  SignInDemo
//
//  Created by 김동준 on 10/1/26.
//

import CommonDomain
import CoreAuthTesting

enum SignInScenario: String, CaseIterable, Hashable, Identifiable {
    case onboardingRequired
    case groupOnboardingRequired
    case groupEntry
    case mainAccessible
    case socialTokenMissing
    case socialNetworkFailure
    case socialUnexpectedFailure
    case authNetworkFailure
    case authUnexpectedFailure
    case profileLookupFailure
    case emptyNickname
    case demoLoginDisabled
    case demoLoginCancel
    case demoLoginWrongPassword
    case demoLoginSuccess
    case demoLoginNetworkFailure
    case demoLoginUnexpectedFailure

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .onboardingRequired: "개인 온보딩 필요"
        case .groupOnboardingRequired: "그룹 온보딩 필요"
        case .groupEntry: "그룹 진입"
        case .mainAccessible: "메인 진입"
        case .socialTokenMissing: "소셜 토큰 없음"
        case .socialNetworkFailure: "소셜 인증 네트워크 오류"
        case .socialUnexpectedFailure: "소셜 인증 알 수 없는 오류"
        case .authNetworkFailure: "서버 로그인 네트워크 오류"
        case .authUnexpectedFailure: "서버 로그인 알 수 없는 오류"
        case .profileLookupFailure: "프로필 조회 실패"
        case .emptyNickname: "닉네임 없음"
        case .demoLoginDisabled: "데모 로그인 비활성"
        case .demoLoginCancel: "데모 로그인 취소"
        case .demoLoginWrongPassword: "데모 로그인 비밀번호 오류"
        case .demoLoginSuccess: "데모 로그인 성공"
        case .demoLoginNetworkFailure: "데모 로그인 네트워크 오류"
        case .demoLoginUnexpectedFailure: "데모 로그인 알 수 없는 오류"
        }
    }

    var summary: String {
        switch self {
        case .onboardingRequired:
            "카카오/Apple 로그인 → 개인 정보 입력 경로"
        case .groupOnboardingRequired:
            "카카오/Apple 로그인 → 가입 완료 안내가 있는 그룹 경로"
        case .groupEntry:
            "카카오/Apple 로그인 → 가입 완료 안내가 없는 그룹 경로"
        case .mainAccessible:
            "카카오/Apple 로그인 → 닉네임 조회 후 메인 경로"
        case .socialTokenMissing:
            "카카오/Apple 로그인 → 토큰 없음 → 알 수 없는 오류"
        case .socialNetworkFailure:
            "카카오/Apple 로그인 → 공급자 네트워크 오류"
        case .socialUnexpectedFailure:
            "카카오/Apple 로그인 → 공급자 오류가 알 수 없는 오류로 변환"
        case .authNetworkFailure:
            "카카오/Apple 로그인 → 서버 네트워크 오류"
        case .authUnexpectedFailure:
            "카카오/Apple 로그인 → 서버 오류가 알 수 없는 오류로 변환"
        case .profileLookupFailure:
            "카카오/Apple 로그인 → 프로필 조회 실패에도 메인 경로"
        case .emptyNickname:
            "카카오/Apple 로그인 → 빈 닉네임은 설정하지 않고 메인 경로"
        case .demoLoginDisabled:
            "제목을 20번 탭해도 데모 로그인 창이 열리지 않음"
        case .demoLoginCancel:
            "제목 20번 탭 → 데모 로그인 창에서 취소"
        case .demoLoginWrongPassword:
            "제목 20번 탭 → 77777 이외 비밀번호로 확인"
        case .demoLoginSuccess:
            "제목 20번 탭 → 77777 입력 → 메인 경로"
        case .demoLoginNetworkFailure:
            "제목 20번 탭 → 77777 입력 → 네트워크 오류"
        case .demoLoginUnexpectedFailure:
            "제목 20번 탭 → 77777 입력 → 알 수 없는 오류"
        }
    }

    var expectedNavigationDescription: String {
        switch self {
        case .onboardingRequired:
            "예상 이동: 개인 정보 입력(온보딩)"
        case .groupOnboardingRequired:
            "예상 이동: 그룹 진입 · 가입 완료 안내 표시"
        case .groupEntry:
            "예상 이동: 그룹 진입 · 가입 완료 안내 없음"
        case .mainAccessible, .profileLookupFailure, .emptyNickname, .demoLoginSuccess:
            "예상 이동: 메인"
        case .socialTokenMissing,
             .socialNetworkFailure,
             .socialUnexpectedFailure,
             .authNetworkFailure,
             .authUnexpectedFailure,
             .demoLoginNetworkFailure,
             .demoLoginUnexpectedFailure:
            "예상 이동: 없음 · SignIn에서 오류 표시"
        case .demoLoginDisabled, .demoLoginCancel, .demoLoginWrongPassword:
            "예상 이동: 없음 · SignIn 유지"
        }
    }

    var isDemoLoginEnabled: Bool {
        switch self {
        case .demoLoginCancel,
             .demoLoginWrongPassword,
             .demoLoginSuccess,
             .demoLoginNetworkFailure,
             .demoLoginUnexpectedFailure:
            true
        default:
            false
        }
    }

    var socialLoginResult: Result<String?, Error> {
        switch self {
        case .socialTokenMissing:
            .success(nil)
        case .socialNetworkFailure:
            .failure(NetworkError.networkUnavailable)
        case .socialUnexpectedFailure:
            .failure(SignInDemoUnexpectedError())
        default:
            .success("demo-social-token")
        }
    }

    var signInResult: Result<AuthSession, Error> {
        switch self {
        case .authNetworkFailure, .demoLoginNetworkFailure:
            .failure(NetworkError.networkUnavailable)
        case .authUnexpectedFailure, .demoLoginUnexpectedFailure:
            .failure(SignInDemoUnexpectedError())
        default:
            .success(authSession)
        }
    }

    var userInfoResult: Result<UserInfo, Error> {
        switch self {
        case .profileLookupFailure:
            .failure(NetworkError.networkUnavailable)
        case .emptyNickname:
            .success(UserInfoFixture.make(nickname: ""))
        default:
            .success(UserInfoFixture.make())
        }
    }

    private var authSession: AuthSession {
        switch self {
        case .onboardingRequired:
            AuthSessionFixture.make(
                personalInfoCompleted: false,
                mainAccessible: false,
                groupOnboardingCompleted: false
            )
        case .groupOnboardingRequired:
            AuthSessionFixture.make(
                mainAccessible: false,
                groupOnboardingCompleted: false
            )
        case .groupEntry:
            AuthSessionFixture.make(mainAccessible: false)
        default:
            AuthSessionFixture.make()
        }
    }
}

private struct SignInDemoUnexpectedError: Error {}
