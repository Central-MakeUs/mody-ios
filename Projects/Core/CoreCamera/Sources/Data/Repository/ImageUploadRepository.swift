//
//  ImageUploadRepository.swift
//  CoreCamera
//
//  Created by 김동준 on 7/25/26.
//

import Alamofire
import CommonDomain
import CoreCameraInterface
import CoreNetworkInterface
import Foundation
import ImageIO
import UniformTypeIdentifiers

public struct ImageUploadRepository: ImageUploadRepositoryProtocol {
    private let network: CoreNetworkProtocol
    private let uploadSession: Session

    public init(network: CoreNetworkProtocol) {
        self.network = network
        self.uploadSession = .default
    }

    public func postPresignedURL(
        domain: ImageUploadDomain,
        fileName: String
    ) async throws -> PresignedImageUpload {
        let endpoint = ImageUploadEndpoint.postPresignedURL(
            domain: domain,
            fileName: fileName
        )
        let response: CoreNetworkResponse<ImageUploadPresignedURLResponse> = try await network.request(endpoint)

        guard let result = response.result,
              let presignedURL = result.presignedUrl,
              !presignedURL.isEmpty,
              let url = URL(string: presignedURL),
              let imageKey = result.imageKey,
              !imageKey.isEmpty else {
            throw NetworkError.invalidResponse
        }

        return PresignedImageUpload(url: url, imageKey: imageKey)
    }

    public func putImage(
        data: Data,
        to url: URL
    ) async throws {
        let contentType = try contentType(for: data)
        let response = await uploadSession
            .upload(
                data,
                to: url,
                method: .put,
                headers: [.contentType(contentType)]
            )
            .validate(statusCode: 200..<300)
            .serializingData(emptyResponseCodes: Set(200..<300))
            .response

        if let error = response.error {
            throw mapUploadError(error)
        }
    }
}

private extension ImageUploadRepository {
    func contentType(for data: Data) throws -> String {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let typeIdentifier = CGImageSourceGetType(imageSource),
              let uniformType = UTType(typeIdentifier as String),
              let contentType = uniformType.preferredMIMEType else {
            throw NetworkError.invalidResponse
        }

        return contentType
    }

    func mapUploadError(_ error: AFError) -> NetworkError {
        guard case let .sessionTaskFailed(underlyingError) = error,
              let urlError = underlyingError as? URLError else {
            return .invalidResponse
        }

        switch urlError.code {
        case .timedOut:
            return .timeout
        case .notConnectedToInternet,
             .networkConnectionLost,
             .cannotConnectToHost,
             .cannotFindHost,
             .dnsLookupFailed,
             .internationalRoamingOff,
             .dataNotAllowed:
            return .networkUnavailable
        default:
            return .unknown
        }
    }
}
