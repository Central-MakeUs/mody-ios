//
//  FeedRecord.swift
//  Feed
//
//  Created by 김동준 on 7/21/26
//

import Foundation

public struct FeedRecordPage: Equatable {
    public let records: [FeedRecord]
    public let nextCursor: Int?
    public let hasNext: Bool

    public init(
        records: [FeedRecord],
        nextCursor: Int?,
        hasNext: Bool
    ) {
        self.records = records
        self.nextCursor = nextCursor
        self.hasNext = hasNext
    }
}

public struct FeedRecord: Equatable {
    public let recordId: Int
    public let recordType: FeedRecordKind
    public let memberId: Int
    public let nickname: String
    public let profileImageUrl: String?
    public let recordedTime: String
    public let menu: String
    public let exerciseDurationMinutes: Int
    public let exerciseName: String
    public let imageUrl: String
    public let imageCropRegion: FeedImageCropRegion?
    public let recordingStreakDays: Int

    public init(
        recordId: Int,
        recordType: FeedRecordKind,
        memberId: Int,
        nickname: String,
        profileImageUrl: String?,
        recordedTime: String,
        menu: String,
        exerciseDurationMinutes: Int,
        exerciseName: String,
        imageUrl: String,
        imageCropRegion: FeedImageCropRegion?,
        recordingStreakDays: Int
    ) {
        self.recordId = recordId
        self.recordType = recordType
        self.memberId = memberId
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.recordedTime = recordedTime
        self.menu = menu
        self.exerciseDurationMinutes = exerciseDurationMinutes
        self.exerciseName = exerciseName
        self.imageUrl = imageUrl
        self.imageCropRegion = imageCropRegion
        self.recordingStreakDays = recordingStreakDays
    }
}

public enum FeedRecordKind: String, Equatable {
    case meal = "MEAL"
    case exercise = "EXERCISE"
}

public struct FeedImageCropRegion: Equatable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(
        x: Double,
        y: Double,
        width: Double,
        height: Double
    ) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}
