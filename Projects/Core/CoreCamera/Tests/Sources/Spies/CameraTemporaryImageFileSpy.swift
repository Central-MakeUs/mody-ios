//  CameraTemporaryImageFileSpy.swift
//  CoreCameraTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreModyImageInterface
import Foundation

final class CameraTemporaryImageFileSpy: TemporaryImageFileUseCaseProtocol {
    enum Call: Equatable {
        case save(Data, String)
        case copy(URL, String)
        case remove(URL)
    }

    private(set) var calls: [Call] = []
    private let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    var saveError: Error?
    var copyError: Error?
    var removeError: Error?

    deinit { try? FileManager.default.removeItem(at: directory) }

    func saveImage(data: Data, fileName: String) throws -> TemporaryImageFile {
        calls.append(.save(data, fileName))
        if let saveError { throw saveError }
        return try write(data: data, fileName: fileName)
    }

    func copyImage(at sourceURL: URL, fileName: String) throws -> TemporaryImageFile {
        calls.append(.copy(sourceURL, fileName))
        if let copyError { throw copyError }
        return try write(data: Data(contentsOf: sourceURL), fileName: fileName)
    }

    func removeImage(at fileURL: URL) throws {
        calls.append(.remove(fileURL))
        if let removeError { throw removeError }
        if fileURL.deletingLastPathComponent().path == directory.path,
            FileManager.default.fileExists(atPath: fileURL.path)
        {
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    func removeExpiredImages(olderThan expirationInterval: TimeInterval) throws {
        preconditionFailure("CoreCamera must not remove unrelated files")
    }

    private func write(data: Data, fileName: String) throws -> TemporaryImageFile {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        try data.write(to: url)
        return TemporaryImageFile(fileURL: url, fileName: fileName, contentType: "image/png")
    }
}
