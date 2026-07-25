//
//  ImageUploadRepositoryProtocol.swift
//  CoreCamera
//
//  Created by 김동준 on 7/25/26.
//

import CoreCameraInterface
import Foundation

public protocol ImageUploadRepositoryProtocol {
    func postPresignedURL(
        domain: ImageUploadDomain,
        fileName: String
    ) async throws -> PresignedImageUpload

    func putImage(
        data: Data,
        to url: URL
    ) async throws
}
