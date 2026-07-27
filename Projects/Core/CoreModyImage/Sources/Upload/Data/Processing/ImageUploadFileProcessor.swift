//
//  ImageUploadFileProcessor.swift
//  CoreModyImage
//
//  Created by 김동준 on 7/26/26.
//

import CommonDomain
import Foundation
import Nuke

struct ImageUploadFileProcessor {
    func makeDownsampledJPEG(
        from sourceURL: URL,
        maximumPixelSize: Int
    ) throws -> URL {
        guard maximumPixelSize > 0 else {
            throw NetworkError.invalidResponse
        }

        let thumbnailOptions = ImageRequest.ThumbnailOptions(
            maxPixelSize: Float(maximumPixelSize)
        )
        let jpegEncoder = ImageEncoders.ImageIO(
            type: .jpeg,
            compressionRatio: 0.9
        )

        guard let sourceData = try? Data(contentsOf: sourceURL, options: .mappedIfSafe),
              let thumbnail = thumbnailOptions.makeThumbnail(with: sourceData),
              let jpegData = jpegEncoder.encode(thumbnail) else {
            throw NetworkError.invalidResponse
        }

        let destinationURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")

        do {
            try jpegData.write(to: destinationURL, options: .atomic)
        } catch {
            try? FileManager.default.removeItem(at: destinationURL)
            throw NetworkError.invalidResponse
        }

        return destinationURL
    }
}
