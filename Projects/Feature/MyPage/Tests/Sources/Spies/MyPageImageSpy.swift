//
//  MyPageImageSpy.swift
//  MyPageTests
//
//  Created by 김동준 on 10/5/26.
//

import Foundation
import CoreModyImageInterface

final class MyPageImageSpy: ImageUploadUseCaseProtocol, TemporaryImageFileUseCaseProtocol {
    var uploadError: Error?
    private(set) var uploads: [(url: URL, name: String, domain: ImageUploadDomain)] = []
    private(set) var removedURLs: [URL] = []

    func uploadImage(fileURL: URL, fileName: String, domain: ImageUploadDomain) async throws -> String {
        uploads.append((fileURL, fileName, domain))
        if let uploadError { throw uploadError }
        return "profile/uploaded-key"
    }
    func saveImage(data: Data, fileName: String) throws -> TemporaryImageFile { throw CancellationError() }
    func copyImage(at sourceURL: URL, fileName: String) throws -> TemporaryImageFile { throw CancellationError() }
    func removeImage(at fileURL: URL) throws { removedURLs.append(fileURL) }
    func removeExpiredImages(olderThan expirationInterval: TimeInterval) throws { throw CancellationError() }
}
