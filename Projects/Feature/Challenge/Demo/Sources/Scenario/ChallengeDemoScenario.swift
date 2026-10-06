//
//  ChallengeDemoScenario.swift
//  ChallengeDemo
//
//  Created by 김동준 on 10/5/26.
//

enum ChallengeDemoScenario: String, CaseIterable, Hashable, Identifiable {
    case overview
    case streakEmpty
    case challengeEmpty
    case bothEmpty
    case stepCompetition
    case stepLive
    case streakSummaryFailure
    case streakNudgeFailure
    case nudgeSuccess
    case nudgeFailure
    case rankingFailure
    case statusFailure
    case stepCompleted
    case stepUpdateFailure
    case weeklyEmpty
    case weeklyListFailure
    case changeOptionsFailure
    case changeSuccess
    case changeFailure
    case weeklyDetailFailure
    case weeklyProofsFailure
    case weeklyProofEmpty
    case weeklyProofSuccess
    case weeklyUploadFailure
    case weeklyProofFailure
    case weeklyPhotoCancel
    case weeklyShareSuccess
    case weeklyShareIncomplete
    case weeklyShareFailure
    case authFailure

    var id: String { rawValue }

    var name: String {
        switch self {
        case .overview: "기본 화면 · 두 탭"
        case .streakEmpty: "연속 기록 빈 화면"
        case .challengeEmpty: "챌린지 빈 화면"
        case .bothEmpty: "둘 다 빈 화면"
        case .stepCompetition: "걸음수 경쟁 시나리오"
        case .stepLive: "걸음수 자동 갱신 3초 + 경쟁 시나리오"
        case .streakSummaryFailure: "연속 기록 요약 조회 실패"
        case .streakNudgeFailure: "콕 찌르기 목록 조회 실패"
        case .nudgeSuccess: "콕 찌르기 성공"
        case .nudgeFailure: "콕 찌르기 실패"
        case .rankingFailure: "걸음 수 랭킹 조회 실패"
        case .statusFailure: "걸음 수 상태 조회 실패"
        case .stepCompleted: "걸음 수 챌린지 완료"
        case .stepUpdateFailure: "걸음 수 기록 갱신 실패"
        case .weeklyEmpty: "주간 챌린지 목록 없음"
        case .weeklyListFailure: "주간 챌린지 목록 조회 실패"
        case .changeOptionsFailure: "챌린지 변경 목록 조회 실패"
        case .changeSuccess: "챌린지 변경 성공"
        case .changeFailure: "챌린지 변경 실패"
        case .weeklyDetailFailure: "주간 상세 조회 실패"
        case .weeklyProofsFailure: "주간 인증 목록 조회 실패"
        case .weeklyProofEmpty: "주간 인증 없음 · 공유 비활성"
        case .weeklyProofSuccess: "주간 인증 사진 등록 성공"
        case .weeklyUploadFailure: "주간 인증 사진 업로드 실패"
        case .weeklyProofFailure: "주간 인증 생성 실패"
        case .weeklyPhotoCancel: "주간 인증 사진 선택 취소"
        case .weeklyShareSuccess: "주간 챌린지 SNS 공유 성공"
        case .weeklyShareIncomplete: "주간 챌린지 미완료 공유 오류"
        case .weeklyShareFailure: "주간 챌린지 SNS 공유 실패"
        case .authFailure: "주간 상세 사용자 조회 실패"
        }
    }

    var instructions: String {
        switch self {
        case .overview, .streakSummaryFailure, .streakNudgeFailure:
            "연속 기록 탭을 확인합니다. 기본 화면에서는 챌린지 탭도 전환합니다."
        case .streakEmpty:
            "콕 찌르기 목록이 비었을 때 표시되는 연속 기록 빈 화면을 확인합니다."
        case .nudgeSuccess, .nudgeFailure:
            "연속 기록 탭에서 첫 번째 멤버의 콕 찌르기 버튼을 누릅니다."
        case .challengeEmpty:
            "챌린지 탭이 바로 열립니다. 걸음수 랭킹이 비었을 때의 빈 화면을 확인합니다."
        case .bothEmpty:
            "연속 기록과 챌린지 탭을 차례로 열어 두 빈 화면을 확인합니다."
        case .rankingFailure, .statusFailure, .stepCompleted,
             .stepUpdateFailure, .weeklyEmpty, .weeklyListFailure:
            "챌린지 탭을 열어 걸음 수와 주간 챌린지 영역을 확인합니다. 기록 갱신은 5초 뒤 실행됩니다."
        case .stepCompetition:
            "챌린지 탭이 바로 열립니다. 시나리오 버튼 왼쪽의 순위 바꾸기를 누르면 7명의 걸음수가 늘며 순위가 바뀝니다."
        case .stepLive:
            "챌린지 탭이 바로 열리고, 3초마다 7명 모두의 걸음수가 자동으로 늘어납니다. 순위가 바뀔 수 있습니다."
        case .changeOptionsFailure, .changeSuccess, .changeFailure:
            "챌린지 탭에서 변경을 누릅니다. 성공·실패 시 두 번째 선택지를 누르고 변경을 확정합니다."
        case .weeklyDetailFailure, .weeklyProofsFailure, .weeklyProofEmpty,
             .weeklyProofSuccess, .weeklyUploadFailure, .weeklyProofFailure,
             .weeklyPhotoCancel, .weeklyShareSuccess, .weeklyShareIncomplete,
             .weeklyShareFailure, .authFailure:
            "챌린지 탭에서 주간 챌린지를 누릅니다. 인증 시나리오는 인증하기 → 카메라/앨범 → 데모 선택을 진행하고, 공유 시나리오는 SNS에 공유하기를 누릅니다."
        }
    }

    var expectedNavigation: String {
        switch self {
        case .changeOptionsFailure, .changeFailure:
            "예상 이동: 챌린지 변경 · 추가 이동 없음"
        case .changeSuccess:
            "예상 이동: 챌린지 변경 → 챌린지 탭"
        case .weeklyDetailFailure, .weeklyProofsFailure, .weeklyProofEmpty,
             .weeklyProofSuccess, .weeklyUploadFailure, .weeklyProofFailure,
             .weeklyPhotoCancel, .weeklyShareSuccess, .weeklyShareIncomplete,
             .weeklyShareFailure, .authFailure:
            "예상 이동: 주간 챌린지 상세 · 뒤로 가기 전까지 추가 이동 없음"
        default:
            "예상 이동: 없음 · 챌린지 홈 유지"
        }
    }
}
