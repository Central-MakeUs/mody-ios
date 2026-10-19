//
//  TemporaryImageFileRepositorySpy.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreModyImageInterface
import CoreModyImageTesting
import Foundation
@testable import CoreModyImage

final class TemporaryImageFileRepositorySpy: TemporaryImageFileRepositoryProtocol {
    let file = TemporaryImageFileFixture.make()
    var error: Error?
    private(set) var savedData: Data?
    private(set) var copiedURL: URL?
    private(set) var fileNames: [String] = []
    private(set) var removedURLs: [URL] = []
    private(set) var expirationIntervals: [TimeInterval] = []

    func saveImage(data: Data, fileName: String) throws -> TemporaryImageFile {
        savedData = data
        fileNames.append(fileName)
        if let error { throw error }
        return file
    }

    func copyImage(at sourceURL: URL, fileName: String) throws -> TemporaryImageFile {
        copiedURL = sourceURL
        fileNames.append(fileName)
        if let error { throw error }
        return file
    }

    func removeImage(at fileURL: URL) throws {
        removedURLs.append(fileURL)
        if let error { throw error }
    }

    func removeExpiredImages(olderThan expirationInterval: TimeInterval) throws {
        expirationIntervals.append(expirationInterval)
        if let error { throw error }
    }
}
