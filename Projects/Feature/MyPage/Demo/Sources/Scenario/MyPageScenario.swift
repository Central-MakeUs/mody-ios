//
//  MyPageScenario.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

enum MyPageScenario: String, CaseIterable, Hashable, Identifiable {
    case overview
    case userLookupFailure
    case weightLookupFailure
    case weightSaveSuccess
    case weightSaveFailure
    case weightInvalidDate
    case profileLookupFailure
    case profileSaveSuccess
    case profileSaveFailure
    case profileUnsavedChanges
    case photoCaptureSuccess
    case photoCaptureCancel
    case photoUploadFailure
    case logoutSuccess
    case logoutFailure
    case deleteSuccess
    case deleteFailure
    case notificationLookupFailure
    case notificationPermissionRequest
    case notificationPermissionDenied
    case notificationToggleFailure
    case notificationSaveDisabled
    case notificationSaveSuccess
    case notificationSaveFailure
    case groupLookupFailure
    case groupExitSuccess
    case groupExitFailure
    case lastGroupExit
    case healthPermissionPrompt

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .overview: "마이페이지 기본 화면"
        case .userLookupFailure: "사용자 조회 실패"
        case .weightLookupFailure: "체중 조회 실패"
        case .weightSaveSuccess: "체중 기록 성공"
        case .weightSaveFailure: "체중 기록 실패"
        case .weightInvalidDate: "체중 날짜 형식 오류"
        case .profileLookupFailure: "프로필 조회 실패"
        case .profileSaveSuccess: "프로필 저장 성공"
        case .profileSaveFailure: "프로필 저장 실패"
        case .profileUnsavedChanges: "프로필 미저장 변경"
        case .photoCaptureSuccess: "프로필 사진 선택·저장"
        case .photoCaptureCancel: "프로필 사진 선택 취소"
        case .photoUploadFailure: "프로필 사진 업로드 실패"
        case .logoutSuccess: "로그아웃 성공"
        case .logoutFailure: "로그아웃 실패"
        case .deleteSuccess: "회원탈퇴 성공"
        case .deleteFailure: "회원탈퇴 실패"
        case .notificationLookupFailure: "알림 설정 조회 실패"
        case .notificationPermissionRequest: "알림 권한 요청 경로"
        case .notificationPermissionDenied: "시스템 알림 권한 꺼짐"
        case .notificationToggleFailure: "알림 토글 저장 실패"
        case .notificationSaveDisabled: "알림 일정 저장 비활성"
        case .notificationSaveSuccess: "알림 일정 저장 성공"
        case .notificationSaveFailure: "알림 일정 저장 실패"
        case .groupLookupFailure: "그룹 조회 실패"
        case .groupExitSuccess: "그룹 나가기 성공"
        case .groupExitFailure: "그룹 나가기 실패"
        case .lastGroupExit: "마지막 그룹 나가기"
        case .healthPermissionPrompt: "건강 권한 요청"
        }
    }

    var summary: String {
        switch self {
        case .overview: "홈의 프로필, 체중, 설정 목록을 확인합니다."
        case .userLookupFailure: "홈을 열면 프로필 조회가 실패해 프로필 영역이 비어 있습니다."
        case .weightLookupFailure: "홈을 열면 체중 조회가 실패해 체중 영역이 비어 있습니다."
        case .weightSaveSuccess, .weightSaveFailure: "체중 기록을 열어 날짜와 체중을 선택한 뒤 기록합니다."
        case .weightInvalidDate: "체중 기록을 열어 날짜를 잘못된 형식으로 입력하고 기록 버튼 비활성을 확인합니다."
        case .profileLookupFailure: "프로필 편집을 열면 프로필 조회 오류가 표시됩니다."
        case .profileSaveSuccess, .profileSaveFailure: "프로필 편집에서 이름을 변경한 뒤 저장합니다."
        case .profileUnsavedChanges: "프로필 편집에서 이름을 변경하고 뒤로 가기를 눌러 계속 수정·저장 안 함을 확인합니다."
        case .photoCaptureSuccess, .photoUploadFailure: "프로필 편집에서 사진을 눌러 카메라/갤러리를 선택하고 데모 사진을 저장합니다."
        case .photoCaptureCancel: "프로필 편집에서 사진을 눌러 카메라/갤러리를 선택하고 취소합니다."
        case .logoutSuccess, .logoutFailure: "프로필 편집에서 로그아웃을 누릅니다."
        case .deleteSuccess, .deleteFailure: "프로필 편집에서 회원탈퇴를 누르고 확인합니다."
        case .notificationLookupFailure: "알림 설정을 열면 조회 오류가 표시됩니다."
        case .notificationPermissionRequest: "알림 설정 진입 시 권한 요청 경로를 실행합니다. 시스템 팝업은 Demo 대역으로 대체됩니다."
        case .notificationPermissionDenied: "알림 설정을 열어 '설정으로 가기' 버튼과 알림 토글·일정 편집 비활성을 확인합니다. 권한은 꺼짐으로 고정됩니다."
        case .notificationToggleFailure: "알림 설정에서 댓글 또는 챌린지 토글을 바꿉니다."
        case .notificationSaveDisabled: "알림 설정에서 꺼진 식사·운동 알림과 저장 버튼 비활성을 확인합니다."
        case .notificationSaveSuccess, .notificationSaveFailure: "알림 설정에서 식사·운동 일정을 변경하고 저장합니다."
        case .groupLookupFailure: "그룹 설정을 열면 조회 오류가 표시됩니다."
        case .groupExitSuccess, .groupExitFailure, .lastGroupExit: "그룹 설정에서 그룹 나가기를 누르고 확인합니다."
        case .healthPermissionPrompt: "건강 데이터 설정 진입 시 권한 요청 경로를 실행합니다. 시스템 팝업은 Demo 대역으로 대체됩니다."
        }
    }

    var expectedNavigation: String {
        switch self {
        case .profileSaveSuccess, .photoCaptureSuccess: "예상 이동: 프로필 → 마이페이지"
        case .logoutSuccess, .deleteSuccess: "예상 이동: 로그인"
        case .lastGroupExit: "예상 이동: 그룹 참여"
        case .overview, .userLookupFailure, .weightLookupFailure,
             .weightSaveSuccess, .weightSaveFailure, .weightInvalidDate:
            "예상 이동: 없음 · 마이페이지 유지"
        case .profileUnsavedChanges:
            "예상 이동: 계속 수정 시 프로필 유지 · 저장 안 함 시 마이페이지"
        case .profileLookupFailure, .profileSaveFailure, .photoCaptureCancel,
             .photoUploadFailure, .logoutFailure, .deleteFailure:
            "예상 이동: 프로필 · 추가 이동 없음"
        case .notificationLookupFailure, .notificationPermissionRequest,
             .notificationToggleFailure, .notificationSaveDisabled,
             .notificationSaveSuccess, .notificationSaveFailure:
            "예상 이동: 알림 설정 · 추가 이동 없음"
        case .notificationPermissionDenied:
            "예상 이동: 알림 설정 → '설정으로 가기' 선택 시 시스템 알림 설정"
        case .groupLookupFailure, .groupExitSuccess, .groupExitFailure:
            "예상 이동: 그룹 설정 · 추가 이동 없음"
        case .healthPermissionPrompt:
            "예상 이동: 건강 데이터 연동 설정 · 추가 이동 없음"
        }
    }
}
