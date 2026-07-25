//
//  NotificationRow.swift
//  Main
//
//  Created by 김동준 on 7/24/26.
//

import CoreNotificationInterface
import DesignSystem
import SwiftUI
import Util

struct NotificationRow: View {
    let notification: NotificationItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                notificationIcon
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray9)
                    .frame(width: 24, height: 24)

                contents

                MText(
                    relativeTime,
                    style: .c4,
                    color: .gray4
                )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color.systemWhite)
        }
    }
}

private extension NotificationRow {
    var notificationIcon: Image {
        switch notification.type {
        case .groupMemberJoined:
            return .icParty
        case .exerciseReminder:
            return .icExercise
        case .mealReminder:
            return .icCook
        case .commentCreated:
            return .icComment
        case .groupRecordStreakRisk:
            return .icFire
        case .buddyNudge:
            return .icFinger
        case .stepChallengeCompleted:
            return .icFootprint
        case .weeklyChallengeCompleted:
            return .icAward
        }
    }

    var relativeTime: String {
        let createdAt = notification.createdAt
        let date = createdAt.toDate(format: .custom("yyyy-MM-dd'T'HH:mm:ss"))
            ?? createdAt.toDate(format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS"))

        return date?.relativeTimeString() ?? String(createdAt.prefix(10))
    }
}

private extension NotificationRow {
    var contents: some View {
        VStack(alignment: .leading, spacing: 4) {
            MText(
                notification.title,
                style: .b6,
                color: .gray10,
                alignment: .leading
            )

            MText(
                notification.description,
                style: .c2,
                color: .gray5,
                alignment: .leading
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
