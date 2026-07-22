//
//  FeedMockRepository.swift
//  FeedTesting
//
//  Created by 김동준 on 7/22/26.
//

import Feed
import Foundation

public actor FeedMockRepository: FeedRepositoryProtocol {
    private var records: [FeedRecord]

    public init() {
        records = Self.defaultRecords
    }

    public func getRecords(
        groupId: Int,
        date: String,
        cursor: Int?,
        size: Int
    ) async throws -> FeedRecordPage {
        try await Task.sleep(nanoseconds: 2_000_000_000)

        guard date == Self.todayString() else {
            return FeedRecordPage(records: [], nextCursor: nil, hasNext: false)
        }

        return FeedRecordPage(
            records: records,
            nextCursor: nil,
            hasNext: false
        )
    }

    public func postRecord(_ request: FeedRecordCreateRequest) async throws {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        let imageURL =
            Self.defaultRecords.randomElement()?.imageUrl
            ?? Self.defaultRecords[0].imageUrl

        records.append(
            FeedRecord(
                recordId: Int(Date().timeIntervalSince1970 * 1_000),
                recordType: request.recordType == .meal ? .meal : .exercise,
                memberId: 4_537_058_591_744,
                nickname: "다함께빡빡빡",
                profileImageUrl: Self.profileImageURL,
                recordedTime: request.mealTime ?? Self.currentTimeString(),
                menu: request.menu ?? "",
                exerciseDurationMinutes: (request.exerciseDurationHours ?? 0) * 60
                    + (request.exerciseDurationMinutes ?? 0),
                exerciseName: request.exerciseName ?? "",
                imageUrl: imageURL,
                imageCropRegion: FeedImageCropRegion(
                    x: request.imageCropRegion.x,
                    y: request.imageCropRegion.y,
                    width: request.imageCropRegion.width,
                    height: request.imageCropRegion.height
                ),
                recordingStreakDays: 1
            )
        )
    }
}

private extension FeedMockRepository {
    static let profileImageURL =
        "https://storage.googleapis.com/mody-images/http://k.kakaocdn.net/dn/mWjnL/btsI9aEAjZF/j4E1KubpKOEibHorQIGyjK/img_640x640.jpg"

    static let defaultRecords: [FeedRecord] = [
        FeedRecord(
            recordId: 4_587_031_102_464,
            recordType: .exercise,
            memberId: 4_537_058_591_744,
            nickname: "다함께빡빡빡",
            profileImageUrl: profileImageURL,
            recordedTime: "21:35",
            menu: "",
            exerciseDurationMinutes: 100,
            exerciseName: "헬스",
            imageUrl:
                "https://storage.googleapis.com/mody-images/records/4537058591744/2026/07/4587030840320.jpg",
            imageCropRegion: FeedImageCropRegion(
                x: 0.22985781990521326,
                y: 0.38151658767772512,
                width: 0.5402843601895736,
                height: 0.23696682464454974
            ),
            recordingStreakDays: 1
        ),
        FeedRecord(
            recordId: 4_587_019_043_841,
            recordType: .exercise,
            memberId: 4_537_058_591_744,
            nickname: "다함께빡빡빡",
            profileImageUrl: profileImageURL,
            recordedTime: "21:34",
            menu: "",
            exerciseDurationMinutes: 120,
            exerciseName: "gdgd",
            imageUrl:
                "https://storage.googleapis.com/mody-images/records/4537058591744/2026/07/4587019043840.png",
            imageCropRegion: FeedImageCropRegion(
                x: 0.061538461538461542,
                y: 0.38151658767772512,
                width: 0.87692307692307692,
                height: 0.23696682464454977
            ),
            recordingStreakDays: 1
        ),
        FeedRecord(
            recordId: 4_586_943_808_512,
            recordType: .exercise,
            memberId: 4_537_058_591_744,
            nickname: "다함께빡빡빡",
            profileImageUrl: profileImageURL,
            recordedTime: "21:30",
            menu: "",
            exerciseDurationMinutes: 5,
            exerciseName: "요가",
            imageUrl:
                "https://storage.googleapis.com/mody-images/records/4537058591744/2026/07/4586943546368.jpg",
            imageCropRegion: FeedImageCropRegion(
                x: 0.35011847889253883,
                y: 0.12993681487313952,
                width: 0.303909952606635,
                height: 0.23696682464454977
            ),
            recordingStreakDays: 1
        ),
        FeedRecord(
            recordId: 4_586_849_698_816,
            recordType: .exercise,
            memberId: 4_537_058_591_744,
            nickname: "다함께빡빡빡",
            profileImageUrl: profileImageURL,
            recordedTime: "21:24",
            menu: "",
            exerciseDurationMinutes: 120,
            exerciseName: "다함께 빡빡빡",
            imageUrl:
                "https://storage.googleapis.com/mody-images/records/4537058591744/2026/07/4586849436672.jpg",
            imageCropRegion: FeedImageCropRegion(
                x: 0.25460769629214802,
                y: 0.37480252161975158,
                width: 0.54028436018957349,
                height: 0.23696682464454974
            ),
            recordingStreakDays: 1
        ),
    ]

    static func todayString() -> String {
        dateFormatter(format: "yyyy-MM-dd").string(from: Date())
    }

    static func currentTimeString() -> String {
        dateFormatter(format: "HH:mm").string(from: Date())
    }

    static func dateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        formatter.dateFormat = format
        return formatter
    }
}
