//
//  ImageUploadRepositoryProtocol.swift
//  CoreModyImage
//
//  Created by 김동준 on 7/25/26.
//

import CoreModyImageInterface
import Foundation

public protocol ImageUploadRepositoryProtocol {
    func postPresignedURL(
        domain: ImageUploadDomain,
        fileName: String
    ) async throws -> PresignedImageUpload

    func putImage(fileURL: URL, to url: URL) async throws
}
