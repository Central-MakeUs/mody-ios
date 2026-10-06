//
//  FeedDemoImageUploadUseCaseStub.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import CoreModyImageInterface
import Foundation

struct FeedDemoImageUploadUseCaseStub: ImageUploadUseCaseProtocol {
    let scenario: FeedDemoScenario

    func uploadImage(fileURL: URL, fileName: String, domain: ImageUploadDomain) async throws -> String {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .uploadFailure { throw NetworkError.invalidResponse }
        return "demo/\(domain.rawValue)/\(fileName)"
    }
}
