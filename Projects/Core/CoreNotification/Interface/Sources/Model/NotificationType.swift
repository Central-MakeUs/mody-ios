//
//  NotificationType.swift
//  CoreNotificationInterface
//
//  Created by 김동준 on 7/23/26.
//

public enum NotificationType: String, Equatable {
    case groupMemberJoined = "GROUP_MEMBER_JOINED"
    case exerciseReminder = "EXERCISE_REMINDER"
    case mealReminder = "MEAL_REMINDER"
    case commentCreated = "COMMENT_CREATED"
    case groupRecordStreakRisk = "GROUP_RECORD_STREAK_RISK"
    case buddyNudge = "BUDDY_NUDGE"
    case stepChallengeCompleted = "STEP_CHALLENGE_COMPLETED"
    case weeklyChallengeCompleted = "WEEKLY_CHALLENGE_COMPLETED"
}
