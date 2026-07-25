//
//  TemporaryImageFileUseCase.swift
//  CoreModyImage
//
//  Created by 김동준 on 7/25/26.
//

import CoreModyImageInterface
import Foundation

public struct TemporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol {
    private let repository: TemporaryImageFileRepositoryProtocol

    public init(repository: TemporaryImageFileRepositoryProtocol) {
        self.repository = repository
    }

    public func saveImage(
        data: Data,
        fileName: String
    ) throws -> TemporaryImageFile {
        try repository.saveImage(data: data, fileName: fileName)
    }

    public func copyImage(
        at sourceURL: URL,
        fileName: String
    ) throws -> TemporaryImageFile {
        try repository.copyImage(at: sourceURL, fileName: fileName)
    }

    public func removeImage(at fileURL: URL) throws {
        try repository.removeImage(at: fileURL)
    }

    public func removeExpiredImages(olderThan expirationInterval: TimeInterval) throws {
        try repository.removeExpiredImages(olderThan: expirationInterval)
    }
}
