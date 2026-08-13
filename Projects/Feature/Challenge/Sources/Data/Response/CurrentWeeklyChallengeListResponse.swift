//
//  CurrentWeeklyChallengeListResponse.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

struct CurrentWeeklyChallengeListResponse: Decodable, Equatable {
    private let challenges: [CurrentWeeklyChallengeResponse]?
}

private struct CurrentWeeklyChallengeResponse: Decodable, Equatable {
    private let groupChallengeId: Int?
    private let title: String?
    private let remainingDays: Int?
    private let participantCount: Int?
    private let randomParticipantNickname: String?
    private let participants: [CurrentWeeklyChallengeParticipantResponse]?
    private let isComplete: Bool?

    func toDomain() -> CurrentWeeklyChallenge {
        CurrentWeeklyChallenge(
            groupChallengeId: groupChallengeId ?? -1,
            title: title ?? "",
            remainingDays: remainingDays ?? 0,
            participantCount: participantCount ?? 0,
            randomParticipantNickname: randomParticipantNickname ?? "",
            participants: (participants ?? []).map { $0.toDomain() },
            isComplete: isComplete ?? false
        )
    }
}

private struct CurrentWeeklyChallengeParticipantResponse: Decodable, Equatable {
    private let memberId: Int?
    private let nickname: String?
    private let profileImageUrl: String?

    func toDomain() -> CurrentWeeklyChallengeParticipant {
        CurrentWeeklyChallengeParticipant(
            memberId: memberId ?? -1,
            nickname: nickname ?? "",
            profileImageUrl: profileImageUrl
        )
    }
}

extension CurrentWeeklyChallengeListResponse {
    func toDomain() -> [CurrentWeeklyChallenge] {
        (challenges ?? []).map { $0.toDomain() }
    }
}
