//
//  ChallengeNudgeInfoResponse.swift
//  Challenge
//
//  Created by 김동준 on 8/3/26.
//

struct ChallengeNudgeInfoResponse: Decodable, Equatable {
    private let members: [ChallengeNudgeMemberResponse]?
}

private struct ChallengeNudgeMemberResponse: Decodable, Equatable {
    let memberId: Int?
    let nickname: String?
    let profileImageUrl: String?
    let recordedToday: Bool?
}

extension ChallengeNudgeInfoResponse {
    func toDomain() -> [ChallengeNudgeInfo] {
        (members ?? []).map { member in
            ChallengeNudgeInfo(
                memberId: member.memberId ?? -1,
                nickname: member.nickname ?? "",
                profileImageUrl: member.profileImageUrl ?? "",
                recordedToday: member.recordedToday ?? false
            )
        }
    }
}
