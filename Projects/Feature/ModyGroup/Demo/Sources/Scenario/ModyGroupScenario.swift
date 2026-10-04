//
//  ModyGroupScenario.swift
//  ModyGroupDemo
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import ModyGroupInterface

enum ModyGroupScenario: String, CaseIterable, Hashable, Identifiable {
    case joinSuccess
    case signUpJoin
    case mainJoin
    case joinCodeNotFound
    case joinGroupFull
    case joinOtherServerError
    case joinNetworkError
    case joinUnexpectedError
    case createFromJoin
    case createFromMain
    case createFromSettings
    case createFailure
    case createUnexpectedError
    case shareFailure

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .joinSuccess: "그룹 참여 성공"
        case .signUpJoin: "가입 완료 후 그룹 참여"
        case .mainJoin: "메인에서 그룹 참여"
        case .joinCodeNotFound: "존재하지 않는 초대 코드"
        case .joinGroupFull: "인원이 꽉 찬 그룹"
        case .joinOtherServerError: "기타 서버 오류"
        case .joinNetworkError: "참여 네트워크 오류"
        case .joinUnexpectedError: "참여 알 수 없는 오류"
        case .createFromJoin: "참여 화면에서 그룹 생성"
        case .createFromMain: "메인에서 그룹 생성"
        case .createFromSettings: "설정에서 그룹 생성"
        case .createFailure: "그룹 생성 실패"
        case .createUnexpectedError: "그룹 생성 알 수 없는 오류"
        case .shareFailure: "카카오 공유 실패"
        }
    }

    var summary: String {
        switch self {
        case .joinSuccess:
            "8자리 코드를 입력해 참여하면 그룹 갱신을 알리고 완료 이동을 요청합니다."
        case .signUpJoin:
            "가입 완료 안내가 표시된 참여 화면에서 코드를 입력하고 참여합니다."
        case .mainJoin:
            "메인에서 열린 참여 화면입니다. 뒤로가기와 참여 완료 이동을 확인합니다."
        case .joinCodeNotFound:
            "8자리 코드로 참여하면 코드가 없다는 입력 오류가 표시됩니다."
        case .joinGroupFull:
            "8자리 코드로 참여하면 그룹 정원 초과 입력 오류가 표시됩니다."
        case .joinOtherServerError:
            "8자리 코드로 참여하면 서버 오류의 fallback 알림이 표시됩니다."
        case .joinNetworkError:
            "8자리 코드로 참여하면 네트워크 오류 알림이 표시됩니다."
        case .joinUnexpectedError:
            "8자리 코드로 참여하면 알 수 없는 오류 알림이 표시됩니다."
        case .createFromJoin:
            "새로운 그룹 만들기 → 이름 입력 → 다음으로 → 초대 화면입니다. 복사, 공유, 완료를 확인합니다."
        case .createFromMain:
            "메인에서 바로 그룹 생성 → 이름 입력 → 다음으로 → 초대 화면입니다. 뒤로가기도 확인합니다."
        case .createFromSettings:
            "설정에서 바로 그룹 생성합니다. 뒤로가기 버튼 없이 시작해 초대 화면으로 이동합니다."
        case .createFailure:
            "새로운 그룹 만들기 → 이름 입력 → 다음으로 누르면 생성 오류 알림이 표시됩니다."
        case .createUnexpectedError:
            "새로운 그룹 만들기 → 이름 입력 → 다음으로 누르면 알 수 없는 오류 알림이 표시됩니다."
        case .shareFailure:
            "그룹 생성 후 초대 화면에서 카카오톡으로 공유하기를 누르면 화면에 머무릅니다."
        }
    }

    var expectedNavigationDescription: String {
        switch self {
        case .joinSuccess, .signUpJoin:
            "예상 이동: 참여 성공 시 완료 · 그룹 갱신 출력"
        case .mainJoin:
            "예상 이동: 뒤로가기 시 뒤로 · 참여 성공 시 완료"
        case .joinCodeNotFound, .joinGroupFull, .joinOtherServerError,
             .joinNetworkError, .joinUnexpectedError:
            "예상 이동: 없음 · 참여 화면에 오류 표시"
        case .createFromJoin, .createFromSettings, .shareFailure:
            "예상 이동: 생성 후 내부 초대 화면 · 완료 시 외부 완료"
        case .createFromMain:
            "예상 이동: 뒤로가기 시 뒤로 · 생성 후 내부 초대 화면 · 완료 시 외부 완료"
        case .createFailure, .createUnexpectedError:
            "예상 이동: 없음 · 생성 화면에 오류 표시"
        }
    }

    var entryPoint: ModyGroupEntryPoint {
        switch self {
        case .mainJoin, .createFromMain: .main
        case .createFromSettings: .groupSettings
        default: .root
        }
    }

    var showSignUpDoneContents: Bool { self == .signUpJoin }

    var initialScreen: ModyGroupInitialScreen {
        switch self {
        case .createFromMain: .create(needBackButton: true)
        case .createFromSettings: .create(needBackButton: false)
        default: .participate
        }
    }

    var createResult: Result<String, Error> {
        if self == .createFailure {
            .failure(NetworkError.networkUnavailable)
        } else if self == .createUnexpectedError {
            .failure(ModyGroupDemoUnexpectedError())
        } else {
            .success("ABCD1234")
        }
    }

    var joinResult: Result<Void, Error> {
        switch self {
        case .joinCodeNotFound:
            .failure(NetworkError.serverError(
                code: ServerErrorCode.group301.code,
                message: nil,
                fallback: .badRequest
            ))
        case .joinGroupFull:
            .failure(NetworkError.serverError(
                code: ServerErrorCode.group304.code,
                message: nil,
                fallback: .badRequest
            ))
        case .joinOtherServerError:
            .failure(NetworkError.serverError(
                code: "GROUP999",
                message: nil,
                fallback: .serverUnavailable
            ))
        case .joinNetworkError:
            .failure(NetworkError.networkUnavailable)
        case .joinUnexpectedError:
            .failure(ModyGroupDemoUnexpectedError())
        default:
            .success(())
        }
    }

    var shareResult: Result<Void, Error> {
        self == .shareFailure
            ? .failure(NetworkError.networkUnavailable)
            : .success(())
    }
}

private struct ModyGroupDemoUnexpectedError: Error {}
