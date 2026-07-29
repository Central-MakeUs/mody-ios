//
//  TemporaryImageFileRepositoryProtocol.swift
//  CoreModyImage
//
//  Created by 김동준 on 7/25/26.
//

import CoreModyImageInterface
import Foundation

public protocol TemporaryImageFileRepositoryProtocol {
    func saveImage(
        data: Data,
        fileName: String
    ) throws -> TemporaryImageFile

    func copyImage(
        at sourceURL: URL,
        fileName: String
    ) throws -> TemporaryImageFile

    func removeImage(at fileURL: URL) throws
    func removeExpiredImages(olderThan expirationInterval: TimeInterval) throws
}
