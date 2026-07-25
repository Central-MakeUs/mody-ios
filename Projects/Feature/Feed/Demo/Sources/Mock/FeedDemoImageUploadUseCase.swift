//
//  FeedDemoImageUploadUseCase.swift
//  FeedDemo
//
//  Created by 김동준 on 7/25/26.
//

import CoreCameraInterface
import Foundation

struct FeedDemoImageUploadUseCase: ImageUploadUseCaseProtocol {
    func uploadImage(
        data: Data,
        fileName: String,
        domain: ImageUploadDomain
    ) async throws -> String {
        "demo/\(domain.rawValue)/\(fileName)"
    }
}
