//
//  OnBoardingScenario.swift
//  OnBoardingDemo
//
//  Created by 김동준 on 10/4/26.
//

import CoreNetworkInterface
import CoreNetworkTesting
import Foundation
import CommonDomain

enum OnBoardingScenario: String, CaseIterable, Hashable, Identifiable {
    case profileSuccess
    case healthPromptSkipped
    case permissionsDenied
    case profileNetworkFailure
    case profileUnexpectedFailure

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .profileSuccess: "프로필 저장 · 권한 요청"
        case .healthPromptSkipped: "건강 권한 요청 생략"
        case .permissionsDenied: "권한 거부 후 진행"
        case .profileNetworkFailure: "프로필 저장 네트워크 오류"
        case .profileUnexpectedFailure: "프로필 저장 알 수 없는 오류"
        }
    }

    var summary: String {
        switch self {
        case .profileSuccess:
            "필수 약관 동의 → 닉네임 입력 → 생년월일·체중 선택 → 운동 요일 선택 → 프로필 저장 → 권한 확인"
        case .healthPromptSkipped:
            "프로필 저장 후 이미 처리된 건강 권한은 다시 요청하지 않고 진행"
        case .permissionsDenied:
            "프로필 저장 후 선택 권한 요청이 거부되어도 그룹 참여로 진행"
        case .profileNetworkFailure:
            "마지막 입력 단계에서 프로필 저장 시 네트워크 오류 표시 · 다시 시도 가능"
        case .profileUnexpectedFailure:
            "마지막 입력 단계에서 알 수 없는 오류 표시 · 다시 시도 가능"
        }
    }

    var expectedNavigationDescription: String {
        switch self {
        case .profileSuccess, .healthPromptSkipped, .permissionsDenied:
            "예상 이동: 그룹 참여 · 권한 확인 후"
        case .profileNetworkFailure, .profileUnexpectedFailure:
            "예상 이동: 없음 · OnBoarding에서 오류 표시"
        }
    }

    var profileResult: Result<Int, Error> {
        switch self {
        case .profileNetworkFailure:
            .failure(NetworkError.networkUnavailable)
        case .profileUnexpectedFailure:
            .failure(OnBoardingDemoUnexpectedError())
        default:
            .success(101)
        }
    }

    var shouldPromptForHealth: Bool { self != .healthPromptSkipped }
    var permissionRequestResult: Bool { self != .permissionsDenied }
}

private struct OnBoardingDemoUnexpectedError: Error {}

extension OnBoardingScenario {
    func networkResponse(to endpoint: CoreNetworkEndpoint) throws -> Data {
        guard endpoint.path == "api/v1/onboarding/profile", endpoint.method == .POST else {
            throw URLError(.unsupportedURL)
        }
        return try CoreNetworkJSONFixture.response(result: ["memberId": self.profileResult.get()])
    }
}
