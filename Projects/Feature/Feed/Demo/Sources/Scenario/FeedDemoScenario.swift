//
//  FeedDemoScenario.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

enum FeedDemoScenario: String, CaseIterable, Identifiable {
    case records
    case noGroups
    case groupFailure
    case emptyFeed
    case feedFailure
    case reportFailure
    case deleteFailure
    case createFailure
    case uploadFailure

    var id: Self { self }

    var title: String {
        switch self {
        case .records: "기록 · 그룹 · 페이지네이션"
        case .noGroups: "가입한 그룹 없음"
        case .groupFailure: "그룹 조회 실패"
        case .emptyFeed: "선택 날짜 기록 없음"
        case .feedFailure: "피드 조회 실패"
        case .reportFailure: "신고 실패"
        case .deleteFailure: "삭제 실패"
        case .createFailure: "기록 생성 실패"
        case .uploadFailure: "사진 업로드 실패"
        }
    }

    var instructions: String {
        switch self {
        case .records:
            "두 그룹을 전환하고 그룹 추가를 누르세요. 날짜를 선택하고 목록을 끝까지 내려 다음 페이지를 확인하세요. 내 카드의 삭제, 다른 사람 카드의 신고, 식사·운동 기록도 실행할 수 있습니다."
        case .noGroups:
            "그룹 조회 결과가 비었을 때 Feed의 빈 화면을 확인하세요."
        case .groupFailure:
            "그룹 조회 오류 후 빈 그룹 상태를 확인하세요."
        case .emptyFeed:
            "기록 없음 화면에서 챌린지 이동 버튼을 누르세요."
        case .feedFailure:
            "그룹은 표시되지만 피드 조회 오류로 목록이 비워지는지 확인하세요."
        case .reportFailure:
            "다른 사람 카드의 더보기 → 신고 → 확인을 누르세요. 오류 알림을 확인하세요."
        case .deleteFailure:
            "내 카드의 더보기 → 삭제 → 확인을 누르세요. 오류 알림을 확인하세요."
        case .createFailure:
            "식사 또는 운동 작성에서 사진을 선택하고 필수 입력을 채운 뒤 완료를 누르세요. 재시도 가능한 오류 알림이 표시됩니다."
        case .uploadFailure:
            "식사 또는 운동 작성에서 사진을 선택하고 필수 입력을 채운 뒤 완료를 누르세요. 업로드 오류 알림이 표시됩니다."
        }
    }

    var expectedNavigation: String {
        switch self {
        case .noGroups: "예상 이동: 없음"
        case .emptyFeed: "예상 이동: 챌린지 요청 (Demo 알림)"
        case .createFailure, .uploadFailure: "예상 이동: 기록 작성 화면 진입 후 오류 시 이동 없음"
        case .records: "예상 이동: 그룹 추가 요청, 식사·운동 작성 진입 및 성공 시 피드 복귀"
        case .groupFailure, .feedFailure, .reportFailure, .deleteFailure: "예상 이동: 없음"
        }
    }
}
