//
//  FeedRepository.swift
//  Feed
//
//  Created by 김동준 on 7/25/26.
//

import CommonDomain
import CoreNetworkInterface

public struct FeedRepository: FeedRepositoryProtocol {
    private let network: CoreNetworkProtocol

    public init(network: CoreNetworkProtocol) {
        self.network = network
    }

    public func getActivityCalendar(groupId: Int, baseDate: String) async throws -> FeedActivityCalendarModel {
        let endpoint = FeedEndpoint.getActivityCalendar(
            groupId: groupId,
            baseDate: baseDate
        )
        let response: CoreNetworkResponse<FeedActivityCalendarResponse> = try await network.request(endpoint)

        guard let result = response.result else {
            throw NetworkError.invalidResponse
        }

        return result.toDomain()
    }
    
    public func getRecords(
        groupId: Int,
        date: String,
        cursor: Int?,
        size: Int
    ) async throws -> FeedRecordPage {
        let endpoint = FeedEndpoint.getRecords(
            groupId: groupId,
            date: date,
            cursor: cursor,
            size: size
        )
        let response: CoreNetworkResponse<FeedRecordListResponse> = try await network.request(endpoint)

        guard let result = response.result else {
            throw NetworkError.invalidResponse
        }

        return result.toDomain()
    }

    public func postRecord(_ request: FeedRecordCreateRequest) async throws {
        let body = FeedRecordCreateBody(
            recordType: request.recordType.rawValue,
            imageKey: request.imageKey,
            mealTime: request.mealTime,
            menu: request.menu,
            exerciseDurationHours: request.exerciseDurationHours,
            exerciseDurationMinutes: request.exerciseDurationMinutes,
            exerciseName: request.exerciseName,
            imageCropRegion: FeedRecordImageCropRegionBody(
                x: request.imageCropRegion.x,
                y: request.imageCropRegion.y,
                width: request.imageCropRegion.width,
                height: request.imageCropRegion.height
            )
        )
        let response: CoreNetworkResponse<CoreNetworkEmptyResponse> = try await network.request(
            FeedEndpoint.postRecord(body)
        )

        guard response.isSuccess != false else {
            throw NetworkError.invalidResponse
        }
    }

    public func postRecordReport(
        groupId: Int,
        recordId: Int
    ) async throws {
        let response: CoreNetworkResponse<CoreNetworkEmptyResponse> = try await network.request(
            FeedEndpoint.postRecordReport(
                groupId: groupId,
                recordId: recordId
            )
        )

        guard response.isSuccess != false else {
            throw NetworkError.invalidResponse
        }
    }

    public func deleteRecord(recordId: Int) async throws {
        let response: CoreNetworkResponse<CoreNetworkEmptyResponse> = try await network.request(
            FeedEndpoint.deleteRecord(recordId: recordId)
        )

        guard response.isSuccess != false else {
            throw NetworkError.invalidResponse
        }
    }
}
