//
//  FeedRepository.swift
//  Feed
//
//  Created by 김동준 on 7/21/26
//

import CommonDomain
import CoreNetworkInterface
import Foundation

public struct FeedRepository: FeedRepositoryProtocol {
    private let network: CoreNetworkProtocol
    private let uploadSession: URLSession

    public init(
        network: CoreNetworkProtocol,
        uploadSession: URLSession = .shared
    ) {
        self.network = network
        self.uploadSession = uploadSession
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
        let presignedUrl = try await postPresignedUrl(fileName: request.imageFileName)
        try await putRecordImage(
            imageData: request.imageData,
            presignedUrl: presignedUrl.presignedUrl,
            fileName: request.imageFileName
        )
        try await postRecordCreate(
            request: request,
            imageKey: presignedUrl.imageKey
        )
    }
}

private extension FeedRepository {
    func postPresignedUrl(fileName: String) async throws -> PresignedRecordImage {
        let endpoint = FeedEndpoint.postPresignedUrl(
            domain: "record",
            fileName: fileName
        )
        let response: CoreNetworkResponse<FeedPresignedUrlResponse> = try await network.request(endpoint)

        guard let result = response.result,
              let presignedUrl = result.presignedUrl,
              let imageKey = result.imageKey,
              !presignedUrl.isEmpty,
              !imageKey.isEmpty else {
            throw NetworkError.invalidResponse
        }

        return PresignedRecordImage(
            presignedUrl: presignedUrl,
            imageKey: imageKey
        )
    }

    func putRecordImage(
        imageData: Data,
        presignedUrl: String,
        fileName: String
    ) async throws {
        guard let url = URL(string: presignedUrl) else {
            throw NetworkError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(contentType(for: fileName), forHTTPHeaderField: "Content-Type")

        do {
            let (_, response) = try await uploadSession.upload(for: request, from: imageData)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.networkUnavailable
        }
    }

    func postRecordCreate(
        request: FeedRecordCreateRequest,
        imageKey: String
    ) async throws {
        let body = FeedRecordCreateBody(
            recordType: request.recordType.rawValue,
            imageKey: imageKey,
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

    func contentType(for fileName: String) -> String {
        switch fileName.split(separator: ".").last?.lowercased() {
        case "png":
            return "image/png"
        default:
            return "image/jpeg"
        }
    }
}

private struct PresignedRecordImage: Equatable {
    let presignedUrl: String
    let imageKey: String
}
