//
//  TemporaryImageFileRepository.swift
//  CoreModyImage
//
//  Created by 김동준 on 7/25/26.
//

import CoreModyImageInterface
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// 원본 바이트를 `ModyUploads` 임시 디렉터리에 보관하고 실제 데이터에서 메타데이터를 읽습니다.
public struct TemporaryImageFileRepository: TemporaryImageFileRepositoryProtocol {
    private let fileManager: FileManager
    private let directoryURL: URL

    public init() {
        self.init(
            fileManager: .default,
            directoryURL: FileManager.default.temporaryDirectory
                .appendingPathComponent("ModyUploads", isDirectory: true)
        )
    }

    init(
        fileManager: FileManager,
        directoryURL: URL
    ) {
        self.fileManager = fileManager
        self.directoryURL = directoryURL
    }

    public func saveImage(
        data: Data,
        fileName: String
    ) throws -> TemporaryImageFile {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let metadata = try makeMetadata(from: imageSource)
        let temporaryFile = try makeTemporaryFile(
            fileName: fileName,
            metadata: metadata
        )
        try data.write(to: temporaryFile.fileURL, options: .atomic)
        return temporaryFile
    }

    public func copyImage(
        at sourceURL: URL,
        fileName: String
    ) throws -> TemporaryImageFile {
        guard let imageSource = CGImageSourceCreateWithURL(sourceURL as CFURL, nil) else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let metadata = try makeMetadata(from: imageSource)
        let temporaryFile = try makeTemporaryFile(
            fileName: fileName,
            metadata: metadata
        )
        try fileManager.copyItem(at: sourceURL, to: temporaryFile.fileURL)
        return temporaryFile
    }

    public func removeImage(at fileURL: URL) throws {
        guard fileManager.fileExists(atPath: fileURL.path) else { return }
        try fileManager.removeItem(at: fileURL)
    }

    public func removeExpiredImages(olderThan expirationInterval: TimeInterval) throws {
        guard fileManager.fileExists(atPath: directoryURL.path) else { return }

        let expirationDate = Date().addingTimeInterval(-expirationInterval)
        let resourceKeys: Set<URLResourceKey> = [.contentModificationDateKey, .isRegularFileKey]
        let fileURLs = try fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsHiddenFiles]
        )

        for fileURL in fileURLs {
            let values = try fileURL.resourceValues(forKeys: resourceKeys)
            guard values.isRegularFile == true,
                  let modificationDate = values.contentModificationDate,
                  modificationDate < expirationDate else {
                continue
            }
            try fileManager.removeItem(at: fileURL)
        }
    }
}

private extension TemporaryImageFileRepository {
    struct ImageMetadata {
        let contentType: String
        let fileExtension: String
    }

    func makeMetadata(from imageSource: CGImageSource) throws -> ImageMetadata {
        guard let typeIdentifier = CGImageSourceGetType(imageSource),
              let imageType = UTType(typeIdentifier as String),
              let contentType = imageType.preferredMIMEType,
              let fileExtension = imageType.preferredFilenameExtension else {
            throw CocoaError(.fileReadCorruptFile)
        }

        return ImageMetadata(
            contentType: contentType,
            fileExtension: fileExtension
        )
    }

    func makeTemporaryFile(
        fileName: String,
        metadata: ImageMetadata
    ) throws -> TemporaryImageFile {
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        let fileURL = directoryURL
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(metadata.fileExtension)

        // 로컬 파일명은 UUID로 충돌을 피하고, 서버에는 별도의 업로드 이름을 전달합니다.
        return TemporaryImageFile(
            fileURL: fileURL,
            fileName: makeUploadFileName(
                fileName,
                fileExtension: metadata.fileExtension
            ),
            contentType: metadata.contentType
        )
    }

    func makeUploadFileName(
        _ fileName: String,
        fileExtension: String
    ) -> String {
        let trimmedFileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseName = URL(fileURLWithPath: trimmedFileName)
            .deletingPathExtension()
            .lastPathComponent

        guard !baseName.isEmpty else {
            let timestamp = ISO8601DateFormatter().string(from: Date())
                .replacingOccurrences(of: ":", with: "")
            return "MODY_PHOTO_\(timestamp)_\(UUID().uuidString).\(fileExtension)"
        }

        return "\(baseName).\(fileExtension)"
    }
}
