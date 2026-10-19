//
//  PhotoFileNameUtil.swift
//  CoreCamera
//
//  Created by 김동준 on 7/23/26.
//

import Foundation
import Photos
import PhotosUI

struct PhotoFileNameUtil {
    static func makeCameraFileName(date: Date = Date(), identifier: UUID = UUID()) -> String {
        makeGeneratedFileName(prefix: "MODY_PHOTO", date: date, identifier: identifier)
    }

    static func makePhotoLibraryFileName(from result: PHPickerResult) -> String {
        makePhotoLibraryFileName(originalFileName: fetchOriginalFileName(from: result))
    }

    static func makePhotoLibraryFileName(
        originalFileName: String?,
        date: Date = Date(),
        identifier: UUID = UUID()
    ) -> String {
        originalFileName ?? makeGeneratedFileName(prefix: "MODY_PHOTO_LIBRARY", date: date, identifier: identifier)
    }

    static func preferredFileName(resources: [(type: PHAssetResourceType, name: String)]) -> String? {
        resources.first { $0.type == .photo || $0.type == .fullSizePhoto }?.name ?? resources.first?.name
    }
}

private extension PhotoFileNameUtil {
    static func makeGeneratedFileName(prefix: String, date: Date, identifier: UUID) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd_HHmmss"

        let timestamp = formatter.string(from: date)
        let suffix = identifier.uuidString.prefix(6).uppercased()
        return "\(prefix)_\(timestamp)_\(suffix).jpg"
    }

    static func fetchOriginalFileName(from result: PHPickerResult) -> String? {
        guard let assetIdentifier = result.assetIdentifier else { return nil }

        let fetchResult = PHAsset.fetchAssets(
            withLocalIdentifiers: [assetIdentifier],
            options: nil
        )
        guard let asset = fetchResult.firstObject else { return nil }

        let resources = PHAssetResource.assetResources(for: asset)
        return preferredFileName(resources: resources.map { ($0.type, $0.originalFilename) })
    }
}
