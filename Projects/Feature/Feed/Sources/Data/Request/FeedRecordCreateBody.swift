//
//  FeedRecordCreateBody.swift
//  Feed
//
//  Created by 김동준 on 7/22/26.
//

struct FeedRecordCreateBody: Encodable, Equatable {
    let recordType: String
    let imageKey: String
    let mealTime: String?
    let menu: String?
    let exerciseDurationHours: Int?
    let exerciseDurationMinutes: Int?
    let exerciseName: String?
    let imageCropRegion: FeedRecordImageCropRegionBody
}

struct FeedRecordImageCropRegionBody: Encodable, Equatable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}
