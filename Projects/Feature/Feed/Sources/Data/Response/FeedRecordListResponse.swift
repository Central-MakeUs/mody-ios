//
//  FeedRecordListResponse.swift
//  Feed
//
//  Created by 김동준 on 7/21/26
//

import Foundation

struct FeedRecordListResponse: Decodable, Equatable {
    let records: [FeedRecordSummaryResponse]?
    let nextCursor: Int?
    let hasNext: Bool?
}

struct FeedRecordSummaryResponse: Decodable, Equatable {
    let recordId: Int?
    let recordType: String?
    let memberId: Int?
    let nickname: String?
    let profileImageUrl: String?
    let recordedTime: String?
    let menu: String?
    let exerciseDurationMinutes: Int?
    let exerciseName: String?
    let imageUrl: String?
    let imageCropRegion: FeedImageCropRegionResponse?
    let recordingStreakDays: Int?
}

struct FeedImageCropRegionResponse: Decodable, Equatable {
    let x: Double?
    let y: Double?
    let width: Double?
    let height: Double?

    func toDomain() -> FeedImageCropRegion? {
        guard let x,
              let y,
              let width,
              let height,
              width > 0,
              height > 0 else {
            return nil
        }

        return FeedImageCropRegion(
            x: x,
            y: y,
            width: width,
            height: height
        )
    }
}

extension FeedRecordListResponse {
    func toDomain() -> FeedRecordPage {
        FeedRecordPage(
            records: (records ?? []).compactMap { $0.toDomain() },
            nextCursor: nextCursor,
            hasNext: hasNext ?? false
        )
    }
}

private extension FeedRecordSummaryResponse {
    func toDomain() -> FeedRecord? {
        guard let imageUrl = imageUrl?.trimmingCharacters(in: .whitespacesAndNewlines),
              !imageUrl.isEmpty else {
            return nil
        }

        return FeedRecord(
            recordId: recordId ?? -1,
            recordType: FeedRecordKind(rawValue: recordType ?? "") ?? .meal,
            memberId: memberId ?? -1,
            nickname: nickname ?? "",
            profileImageUrl: profileImageUrl,
            recordedTime: normalizedRecordedTime,
            menu: menu ?? "",
            exerciseDurationMinutes: exerciseDurationMinutes ?? 0,
            exerciseName: exerciseName ?? "",
            imageUrl: imageUrl,
            imageCropRegion: imageCropRegion?.toDomain(),
            recordingStreakDays: recordingStreakDays ?? 0
        )
    }

    var normalizedRecordedTime: String {
        guard let recordedTime, !recordedTime.isEmpty else { return "" }

        let time = String(recordedTime.prefix(5))
        let components = time.split(separator: ":")

        if components.count == 2 {
            return time
        }

        return recordedTime
    }
}
