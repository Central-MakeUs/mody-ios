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
    static func makeCameraFileName() -> String {
        makeGeneratedFileName(prefix: "MODY_PHOTO")
    }

    static func makePhotoLibraryFileName(from result: PHPickerResult) -> String {
        if let originalFileName = fetchOriginalFileName(from: result) {
            return originalFileName
        }

        return makeGeneratedFileName(prefix: "MODY_PHOTO_LIBRARY")
    }
}

private extension PhotoFileNameUtil {
    static func makeGeneratedFileName(prefix: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd_HHmmss"

        let timestamp = formatter.string(from: Date())
        let suffix = UUID().uuidString.prefix(6).uppercased()
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
        return resources.first {
            $0.type == .photo || $0.type == .fullSizePhoto
        }?.originalFilename ?? resources.first?.originalFilename
    }
}
