//
//  ImageUploadUseCase.swift
//  CoreModyImage
//
//  Created by 김동준 on 7/25/26.
//

import CoreModyImageInterface
import Foundation

public struct ImageUploadUseCase: ImageUploadUseCaseProtocol {
    private let repository: ImageUploadRepositoryProtocol

    public init(repository: ImageUploadRepositoryProtocol) {
        self.repository = repository
    }

    public func uploadImage(
        fileURL: URL,
        fileName: String,
        domain: ImageUploadDomain
    ) async throws -> String {
        let presignedUpload = try await repository.postPresignedURL(
            domain: domain,
            fileName: fileName
        )
        try await repository.putImage(
            fileURL: fileURL,
            to: presignedUpload.url
        )

        return presignedUpload.imageKey
    }
}
