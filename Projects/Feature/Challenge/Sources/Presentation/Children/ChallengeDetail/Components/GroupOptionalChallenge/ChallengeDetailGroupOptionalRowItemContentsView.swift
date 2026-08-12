//
//  ChallengeDetailGroupOptionalRowItemContentsView.swift
//  Challenge
//
//  Created by 김동준 on 8/10/26.
//

import Base
import CommonDomain
import CoreModyImageInterface
import DesignSystem
import Foundation
import SwiftUI

struct ChallengeDetailGroupOptionalRowItemContentsView: View {
    private let challenge: CurrentWeeklyChallenge?
    private let imageLoader: RemoteImageLoading

    init(
        challenge: CurrentWeeklyChallenge?,
        imageLoader: RemoteImageLoading
    ) {
        self.challenge = challenge
        self.imageLoader = imageLoader
    }

    @ViewBuilder
    var body: some View {
        if let challenge {
            if challenge.participants.isEmpty {
                emptyContents
            } else {
                participantContents(challenge)
            }
        } else {
            skeletonContents
        }
    }
}

private extension ChallengeDetailGroupOptionalRowItemContentsView {
    var emptyContents: some View {
        MText(
            "아직 아무도 참여하지 않았어요!",
            style: .c2,
            color: .gray8,
            alignment: .leading
        )
        .greedyWidth(.leading)
    }

    func participantContents(_ challenge: CurrentWeeklyChallenge) -> some View {
        HStack(spacing: 8) {
            participantAvatars(challenge)

            MText(
                participantDescription(challenge),
                style: .c2,
                color: .gray8,
                alignment: .leading
            )
            .greedyWidth(.leading)
        }
    }

    var skeletonContents: some View {
        HStack(spacing: 8) {
            skeletonAvatars

            SkeletonView(width: 211, height: 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipped()
        }
    }

    func participantAvatars(_ challenge: CurrentWeeklyChallenge) -> some View {
        let participants = Array(challenge.participants.prefix(3))
        let additionalParticipantCount = max(
            challenge.participantCount - participants.count,
            0
        )

        return HStack(spacing: -14) {
            ForEach(participants, id: \.memberId) { participant in
                RemoteAvatarView(
                    imageURL: profileImageURL(participant),
                    defaultAvatar: defaultAvatar(participant),
                    width: 32,
                    height: 32,
                    imageLoader: imageLoader
                )
                .overlay {
                    Circle()
                        .strokeBorder(Color.systemWhite, lineWidth: 1)
                }
            }

            if additionalParticipantCount > 0 {
                MText(
                    "+\(additionalParticipantCount)",
                    style: .c1,
                    color: .gray10
                )
                .frame(width: 32, height: 32)
                .background(Color.systemWhite)
                .clipShape(Circle())
            }
        }
    }

    var skeletonAvatars: some View {
        HStack(spacing: -14) {
            ForEach(0..<4, id: \.self) { _ in
                SkeletonView(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .strokeBorder(Color.systemWhite, lineWidth: 1)
                    }
            }
        }
    }

    func profileImageURL(_ participant: CurrentWeeklyChallengeParticipant) -> URL? {
        guard let profileImageURL = participant.profileImageUrl?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !profileImageURL.isEmpty else {
            return nil
        }

        if let url = URL(string: profileImageURL) {
            return url
        }

        return profileImageURL
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            .flatMap(URL.init(string:))
    }

    func defaultAvatar(_ participant: CurrentWeeklyChallengeParticipant) -> DefaultAvatar {
        let avatars = DefaultAvatar.allCases
        let index = Int(participant.memberId.magnitude % UInt(avatars.count))
        return avatars[index]
    }

    func participantDescription(_ challenge: CurrentWeeklyChallenge) -> String {
        let additionalParticipantCount = max(challenge.participantCount - 1, 0)
        return "\(challenge.randomParticipantNickname)님 외 \(additionalParticipantCount)명이 참여하고 있어요!"
    }
}
