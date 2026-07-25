//
//  FeedRecordCreateRequest.swift
//  Feed
//
//  Created by 김동준 on 7/22/26.
//

public struct FeedRecordCreateRequest: Equatable {
    public let recordType: FeedRecordCreateType
    public let imageKey: String
    public let mealTime: String?
    public let menu: String?
    public let exerciseDurationHours: Int?
    public let exerciseDurationMinutes: Int?
    public let exerciseName: String?
    public let imageCropRegion: FeedRecordImageCropRegionRequest

    public init(
        recordType: FeedRecordCreateType,
        imageKey: String,
        mealTime: String? = nil,
        menu: String? = nil,
        exerciseDurationHours: Int? = nil,
        exerciseDurationMinutes: Int? = nil,
        exerciseName: String? = nil,
        imageCropRegion: FeedRecordImageCropRegionRequest
    ) {
        self.recordType = recordType
        self.imageKey = imageKey
        self.mealTime = mealTime
        self.menu = menu
        self.exerciseDurationHours = exerciseDurationHours
        self.exerciseDurationMinutes = exerciseDurationMinutes
        self.exerciseName = exerciseName
        self.imageCropRegion = imageCropRegion
    }
}

public enum FeedRecordCreateType: String, Equatable {
    case meal = "MEAL"
    case exercise = "EXERCISE"
}

public struct FeedRecordImageCropRegionRequest: Equatable {
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
