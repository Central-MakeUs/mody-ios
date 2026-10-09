//
//  ImageUploadRepositorySpy.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 10/9/26.
//

import CommonDomain
import CoreModyImageInterface
import Foundation
@testable import CoreModyImage

final class ImageUploadRepositorySpy: ImageUploadRepositoryProtocol {
    struct PresignedCall: Equatable {
        let domain: ImageUploadDomain
        let fileName: String
    }
    struct UploadCall: Equatable {
        let fileURL: URL
        let destinationURL: URL
        let maximumPixelSize: Int?
    }

    var presignedResult: Result<PresignedImageUpload, NetworkError> = .success(
        PresignedImageUpload(url: URL(string: "https://upload.invalid/image")!, imageKey: "image-key")
    )
    var uploadError: NetworkError?
    private(set) var presignedCalls: [PresignedCall] = []
    private(set) var uploads: [UploadCall] = []
    private(set) var events: [String] = []

    func postPresignedURL(domain: ImageUploadDomain, fileName: String) async throws -> PresignedImageUpload {
        events.append("presigned")
        presignedCalls.append(PresignedCall(domain: domain, fileName: fileName))
        return try presignedResult.get()
    }

    func putImage(fileURL: URL, to url: URL, maximumPixelSize: Int?) async throws {
        events.append("upload")
        uploads.append(UploadCall(fileURL: fileURL, destinationURL: url, maximumPixelSize: maximumPixelSize))
        if let uploadError { throw uploadError }
    }
}
