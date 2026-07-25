//
//  ImageUploadUseCase.swift
//  CoreCamera
//
//  Created by 김동준 on 7/25/26.
//

import CoreCameraInterface
import Foundation

public struct ImageUploadUseCase: ImageUploadUseCaseProtocol {
    private let repository: ImageUploadRepositoryProtocol

    public init(repository: ImageUploadRepositoryProtocol) {
        self.repository = repository
    }

    public func uploadImage(
        data: Data,
        fileName: String,
        domain: ImageUploadDomain
    ) async throws -> String {
        let presignedUpload = try await repository.postPresignedURL(
            domain: domain,
            fileName: fileName
        )
        try await repository.putImage(
            data: data,
            to: presignedUpload.url
        )

        return presignedUpload.imageKey
    }
}
