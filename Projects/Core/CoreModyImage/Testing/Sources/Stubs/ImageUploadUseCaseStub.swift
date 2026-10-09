//
//  ImageUploadUseCaseStub.swift
//  CoreModyImageTesting
//
//  Created by 김동준 on 10/9/26.
//

import CoreModyImageInterface
import Foundation

public struct ImageUploadUseCaseStub: ImageUploadUseCaseProtocol {
    private let uploadHandler: (URL, String, ImageUploadDomain) async throws -> String
    private let responseDelay: Duration

    public init(
        result: Result<String, Error>,
        responseDelay: Duration = .zero
    ) {
        self.init(uploadImage: { _, _, _ in try result.get() }, responseDelay: responseDelay)
    }

    public init(
        uploadImage: @escaping (URL, String, ImageUploadDomain) async throws -> String = { _, _, _ in
            throw CoreModyImageStubError.unexpectedCall("uploadImage")
        },
        responseDelay: Duration = .zero
    ) {
        self.uploadHandler = uploadImage
        self.responseDelay = responseDelay
    }

    public func uploadImage(fileURL: URL, fileName: String, domain: ImageUploadDomain) async throws -> String {
        if responseDelay > .zero {
            try await Task.sleep(for: responseDelay)
        }
        return try await uploadHandler(fileURL, fileName, domain)
    }
}
