//
//  FeedUseCase.swift
//  Feed
//
//  Created by 김동준 on 7/25/26.
//

import Foundation
import FeedInterface

public struct FeedUseCase {
    private let feedRepository: FeedRepositoryProtocol

    public init(feedRepository: FeedRepositoryProtocol) {
        self.feedRepository = feedRepository
    }

    public func fetchFeedRecords(
        groupId: Int,
        date: String,
        cursor: Int?,
        size: Int = 5
    ) async throws -> FeedRecordPage {
        try await feedRepository.getRecords(
            groupId: groupId,
            date: date,
            cursor: cursor,
            size: size
        )
    }
    
    public func fetchActivityCalendar(groupId: Int, baseDate: String) async throws -> FeedActivityCalendarModel {
        try await feedRepository.getActivityCalendar(
            groupId: groupId,
            baseDate: baseDate
        )
    }

    public func createRecord(_ request: FeedRecordCreateRequest) async throws {
        try await feedRepository.postRecord(request)
    }

    public func makeRecordCreationRequest(
        imageKey: String,
        recordType: FeedRecordType,
        mealTime: Date,
        mealMenu: String,
        exerciseType: FeedExerciseType?,
        customExerciseName: String,
        exerciseDurationHours: Int,
        exerciseDurationMinutes: Int,
        normalizedImageCropRegion: CGRect
    ) -> FeedRecordCreateRequest? {
        guard normalizedImageCropRegion.width > 0,
              normalizedImageCropRegion.height > 0 else {
            return nil
        }

        let imageCropRegion = makeImageCropRegionRequest(
            from: normalizedImageCropRegion
        )

        switch recordType {
        case .meal:
            let calendar = Self.koreanCalendar()
            let hour = calendar.component(.hour, from: mealTime)
            let minute = calendar.component(.minute, from: mealTime)

            return FeedRecordCreateRequest(
                recordType: .meal,
                imageKey: imageKey,
                mealTime: String(format: "%02d:%02d", hour, minute),
                menu: mealMenu.trimmingCharacters(in: .whitespacesAndNewlines),
                imageCropRegion: imageCropRegion
            )
        case .exercise:
            guard let exerciseType else { return nil }
            let exerciseName = exerciseType == .custom
                ? customExerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
                : exerciseType.name

            return FeedRecordCreateRequest(
                recordType: .exercise,
                imageKey: imageKey,
                exerciseDurationHours: exerciseDurationHours,
                exerciseDurationMinutes: exerciseDurationMinutes,
                exerciseName: exerciseName,
                imageCropRegion: imageCropRegion
            )
        }
    }
}

private extension FeedUseCase {
    func makeImageCropRegionRequest(
        from region: CGRect
    ) -> FeedRecordImageCropRegionRequest {
        FeedRecordImageCropRegionRequest(
            x: clampedNormalizedValue(Double(region.origin.x)),
            y: clampedNormalizedValue(Double(region.origin.y)),
            width: clampedNormalizedValue(Double(region.width)),
            height: clampedNormalizedValue(Double(region.height))
        )
    }

    func clampedNormalizedValue(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    static func koreanCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        return calendar
    }
}
