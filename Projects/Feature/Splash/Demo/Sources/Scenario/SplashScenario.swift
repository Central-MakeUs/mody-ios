//
//  SplashScenario.swift
//  SplashDemo
//
//  Created by 김동준 on 9/29/26.
//

import CommonDomain
import Splash

enum SplashScenario: String, CaseIterable, Hashable, Identifiable {
    case forceUpdate
    case minimumSupportedVersion
    case skippableNotice
    case blockingNotice
    case serverUnstable
    case healthCheckFailure
    case signedOut
    case onboardingRequired
    case groupOnboardingRequired
    case mainAccessible

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .forceUpdate:
            "강제 업데이트"
        case .minimumSupportedVersion:
            "최소 지원 버전 미달"
        case .skippableNotice:
            "건너뛸 수 있는 공지"
        case .blockingNotice:
            "차단 공지"
        case .serverUnstable:
            "서버 점검 중"
        case .healthCheckFailure:
            "Health Check 실패"
        case .signedOut:
            "인증 실패"
        case .onboardingRequired:
            "온보딩 필요"
        case .groupOnboardingRequired:
            "그룹 온보딩 필요"
        case .mainAccessible:
            "메인 진입 가능"
        }
    }

    var summary: String {
        switch self {
        case .forceUpdate:
            "Remote Config의 강제 업데이트 플래그가 활성화된 상태"
        case .minimumSupportedVersion:
            "현재 Demo 버전보다 최소 지원 버전이 높은 상태"
        case .skippableNotice:
            "확인 후 앱 시작을 계속할 수 있는 공지"
        case .blockingNotice:
            "확인 버튼이 비활성화되어 Splash에 머무는 공지"
        case .serverUnstable:
            "Health Check가 불안정 상태를 반환하는 경우"
        case .healthCheckFailure:
            "Health Check 요청 자체가 실패하는 경우"
        case .signedOut:
            "사용자 정보 조회가 실패해 로그인으로 이동하는 경우"
        case .onboardingRequired:
            "개인 정보 입력이 완료되지 않은 사용자"
        case .groupOnboardingRequired:
            "개인 정보 입력 후 그룹 진입이 필요한 사용자"
        case .mainAccessible:
            "모든 시작 조건을 충족해 메인으로 이동하는 사용자"
        }
    }

    var notice: NoticePopupInfo? {
        switch self {
        case .skippableNotice:
            NoticePopupInfo(
                title: "서비스 안내",
                contents: "확인 후 앱 시작을 계속할 수 있는 공지입니다.",
                skipPossible: true
            )
        case .blockingNotice:
            NoticePopupInfo(
                title: "서비스 점검 중",
                contents: "현재는 앱을 이용할 수 없는 차단 공지입니다.",
                skipPossible: false
            )
        default:
            nil
        }
    }

    var userInfo: UserInfo? {
        switch self {
        case .signedOut:
            nil
        case .onboardingRequired:
            makeUserInfo(
                personalInfoCompleted: false,
                groupOnboardingCompleted: false,
                mainAccessible: false
            )
        case .groupOnboardingRequired:
            makeUserInfo(
                personalInfoCompleted: true,
                groupOnboardingCompleted: false,
                mainAccessible: false
            )
        default:
            makeUserInfo(
                personalInfoCompleted: true,
                groupOnboardingCompleted: true,
                mainAccessible: true
            )
        }
    }
}

private extension SplashScenario {
    func makeUserInfo(
        personalInfoCompleted: Bool,
        groupOnboardingCompleted: Bool,
        mainAccessible: Bool
    ) -> UserInfo {
        UserInfo(
            memberId: 1,
            nickname: "모디",
            profileImageUrl: nil,
            daysTogether: 0,
            personalInfoCompleted: personalInfoCompleted,
            groupOnboardingCompleted: groupOnboardingCompleted,
            mainAccessible: mainAccessible
        )
    }
}
