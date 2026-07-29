//
//  ImageUploadRepository.swift
//  CoreModyImage
//
//  Created by 김동준 on 7/25/26.
//

import Alamofire
import CommonDomain
import CoreModyImageInterface
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
        fileURL: URL,
        to url: URL,
        maximumPixelSize: Int?
    ) async throws {
        let uploadFileURL: URL
        if let maximumPixelSize {
            uploadFileURL = try ImageUploadFileProcessor().makeDownsampledJPEG(
                from: fileURL,
                maximumPixelSize: maximumPixelSize
            )
        } else {
            uploadFileURL = fileURL
        }
        defer {
            if uploadFileURL != fileURL {
                try? FileManager.default.removeItem(at: uploadFileURL)
            }
        }

        let contentType = try contentType(for: uploadFileURL)
        let response = await uploadSession
            .upload(
                uploadFileURL,
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
    func contentType(for fileURL: URL) throws -> String {
        guard let imageSource = CGImageSourceCreateWithURL(
            fileURL as CFURL,
            [kCGImageSourceShouldCache: false] as CFDictionary
        ),
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
