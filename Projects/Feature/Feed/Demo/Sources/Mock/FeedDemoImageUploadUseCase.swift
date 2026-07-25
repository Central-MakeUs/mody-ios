//
//  FeedDemoImageUploadUseCase.swift
//  FeedDemo
//
//  Created by 김동준 on 7/25/26.
//

import CoreModyImageInterface
import Foundation

struct FeedDemoImageUploadUseCase: ImageUploadUseCaseProtocol {
    func uploadImage(
        fileURL: URL,
        fileName: String,
        domain: ImageUploadDomain
    ) async throws -> String {
        "demo/\(domain.rawValue)/\(fileName)"
    }
}
