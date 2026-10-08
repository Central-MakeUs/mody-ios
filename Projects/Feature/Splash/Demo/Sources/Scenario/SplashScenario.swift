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
            "실행 후 강제 업데이트 팝업을 확인합니다. 업데이트 버튼은 App Store를 엽니다."
        case .minimumSupportedVersion:
            "실행 후 지원 종료 버전 팝업을 확인합니다. 업데이트 버튼은 App Store를 엽니다."
        case .skippableNotice:
            "실행 후 공지의 확인 버튼을 누르면 앱 시작 절차를 계속합니다."
        case .blockingNotice:
            "실행 후 확인 버튼을 누를 수 없는 차단 공지를 확인합니다."
        case .serverUnstable:
            "실행 후 서버 점검 상태를 반환해 오류 팝업을 표시합니다."
        case .healthCheckFailure:
            "실행 후 Health Check 요청이 실패해 오류 팝업을 표시합니다."
        case .signedOut:
            "실행 후 사용자 정보 조회가 실패하면 로그인 경로를 요청합니다."
        case .onboardingRequired:
            "실행 후 개인 정보 입력이 필요한 사용자의 온보딩 경로를 요청합니다."
        case .groupOnboardingRequired:
            "실행 후 그룹 진입이 필요한 사용자의 가입 완료 안내 경로를 요청합니다."
        case .mainAccessible:
            "실행 후 모든 시작 조건을 통과해 메인 경로를 요청합니다."
        }
    }

    var expectedNavigationDescription: String {
        switch self {
        case .forceUpdate:
            "예상 이동: 없음 · 강제 업데이트 팝업"
        case .minimumSupportedVersion:
            "예상 이동: 없음 · 지원 종료 버전 팝업"
        case .skippableNotice:
            "예상 이동: 메인 · 공지 확인 후"
        case .blockingNotice:
            "예상 이동: 없음 · 차단 공지에서 Splash 유지"
        case .serverUnstable, .healthCheckFailure:
            "예상 이동: 없음 · 오류 팝업에서 Splash 유지"
        case .signedOut:
            "예상 이동: 로그인"
        case .onboardingRequired:
            "예상 이동: 개인 정보 입력(온보딩)"
        case .groupOnboardingRequired:
            "예상 이동: 그룹 진입 · 가입 완료 안내 표시"
        case .mainAccessible:
            "예상 이동: 메인"
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

    var userInfoResult: Result<UserInfo, Error> {
        switch self {
        case .signedOut:
            .failure(SplashDemoScenarioError.signedOut)
        case .onboardingRequired:
            .success(
                makeUserInfo(
                    personalInfoCompleted: false,
                    groupOnboardingCompleted: false,
                    mainAccessible: false
                )
            )
        case .groupOnboardingRequired:
            .success(
                makeUserInfo(
                    personalInfoCompleted: true,
                    groupOnboardingCompleted: false,
                    mainAccessible: false
                )
            )
        default:
            .success(
                makeUserInfo(
                    personalInfoCompleted: true,
                    groupOnboardingCompleted: true,
                    mainAccessible: true
                )
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

private enum SplashDemoScenarioError: Error {
    case signedOut
}
