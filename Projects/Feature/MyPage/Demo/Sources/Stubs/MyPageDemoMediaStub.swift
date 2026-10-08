//
//  MyPageDemoMediaStub.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import CoreModyImageInterface
import Foundation

struct MyPageDemoImageStub: ImageUploadUseCaseProtocol, TemporaryImageFileUseCaseProtocol {
    private let scenario: MyPageScenario

    init(scenario: MyPageScenario = .overview) {
        self.scenario = scenario
    }

    func uploadImage(fileURL: URL, fileName: String, domain: ImageUploadDomain) async throws -> String {
        if scenario == .photoUploadFailure {
            throw NetworkError.networkUnavailable
        }
        return "demo-profile-image"
    }

    func saveImage(data: Data, fileName: String) throws -> TemporaryImageFile {
        TemporaryImageFile(fileURL: URL(fileURLWithPath: "/tmp/\(fileName)"), fileName: fileName, contentType: "image/jpeg")
    }

    func copyImage(at sourceURL: URL, fileName: String) throws -> TemporaryImageFile {
        TemporaryImageFile(fileURL: sourceURL, fileName: fileName, contentType: "image/jpeg")
    }

    func removeImage(at fileURL: URL) throws {}
    func removeExpiredImages(olderThan expirationInterval: TimeInterval) throws {}
}
