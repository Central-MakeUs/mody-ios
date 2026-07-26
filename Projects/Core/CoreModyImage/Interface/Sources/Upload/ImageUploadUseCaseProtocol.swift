//
//  ImageUploadUseCaseProtocol.swift
//  CoreModyImageInterface
//
//  Created by 김동준 on 7/25/26.
//

import Foundation

public protocol ImageUploadUseCaseProtocol {
    func uploadImage(
        fileURL: URL,
        fileName: String,
        domain: ImageUploadDomain
    ) async throws -> String
}
