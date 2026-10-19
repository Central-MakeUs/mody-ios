//
//  FeedRecordDependencySpies.swift
//  FeedTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import CoreModyImageInterface
import Foundation
import FeedInterface

@MainActor
final class FeedRecordRouterSpy: FeedRecordRouter {
    private(set) var routes: [FeedRecordRoute] = []

    func route(from route: FeedRecordRoute) {
        routes.append(route)
    }
}

final class FeedImageUploadSpy: ImageUploadUseCaseProtocol {
    var result: Result<String, Error> = .success("uploaded-image-key")
    private(set) var fileURLs: [URL] = []
    private(set) var domains: [ImageUploadDomain] = []

    func uploadImage(fileURL: URL, fileName: String, domain: ImageUploadDomain) async throws -> String {
        fileURLs.append(fileURL)
        domains.append(domain)
        return try result.get()
    }
}

final class FeedTemporaryImageFileSpy: TemporaryImageFileUseCaseProtocol {
    private(set) var removedURLs: [URL] = []

    func saveImage(data: Data, fileName: String) throws -> TemporaryImageFile {
        throw NetworkError.unknown
    }

    func copyImage(at sourceURL: URL, fileName: String) throws -> TemporaryImageFile {
        throw NetworkError.unknown
    }

    func removeImage(at fileURL: URL) throws {
        removedURLs.append(fileURL)
    }

    func removeExpiredImages(olderThan expirationInterval: TimeInterval) throws {}
}
