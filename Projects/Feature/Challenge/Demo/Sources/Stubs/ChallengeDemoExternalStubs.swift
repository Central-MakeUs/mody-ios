//
//  ChallengeDemoExternalStubs.swift
//  ChallengeDemo
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import CoreHealthInterface
import CoreModyImage
import CoreModyImageInterface
import Foundation
import UIKit

struct ChallengeDemoHealthStub: HealthUseCaseProtocol {
    private let scenario: ChallengeDemoScenario
    private let data: ChallengeDemoData

    init(scenario: ChallengeDemoScenario, data: ChallengeDemoData) {
        self.scenario = scenario
        self.data = data
    }

    func getStepCount(from startDate: Date, to endDate: Date) async throws -> Int {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .stepCompetition || scenario == .stepLive {
            return await data.simulatedSelfStepCount(for: scenario)
        }
        return 3_400
    }

    func getCurrentMonthStepCount() async throws -> Int {
        try await Task.sleep(for: .milliseconds(500))
        return 42_000
    }
}

struct ChallengeDemoImageStub: ImageUploadUseCaseProtocol, TemporaryImageFileUseCaseProtocol {
    private let scenario: ChallengeDemoScenario

    init(scenario: ChallengeDemoScenario) { self.scenario = scenario }

    func uploadImage(fileURL: URL, fileName: String, domain: ImageUploadDomain) async throws -> String {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .weeklyUploadFailure { throw NetworkError.networkUnavailable }
        return "challenge-demo-proof"
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

final class ChallengeDemoImageLoader: RemoteImageLoading, @unchecked Sendable {
    private let imageLoader = NukeRemoteImageLoader()

    func cachedImage(for request: RemoteImageRequest) -> UIImage? {
        nil
    }

    func loadImage(with request: RemoteImageRequest) async throws -> UIImage {
        try await Task.sleep(for: .milliseconds(500))
        let resource: String
        switch request.url.lastPathComponent {
        case "donggyu.jpg": resource = "ChallengeDemoDonggyu"
        case "dongjun.jpg", "mine.jpg": resource = "ChallengeDemoDongjun"
        default: resource = "ChallengeDemoWalking"
        }
        let fileExtension = resource == "ChallengeDemoWalking" ? "jpg" : "png"
        guard let url = Bundle.main.url(forResource: resource, withExtension: fileExtension) else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try await imageLoader.loadImage(with: RemoteImageRequest(
            url: url,
            variantIdentifier: request.variantIdentifier,
            maximumPixelSize: request.maximumPixelSize,
            processing: request.processing
        ))
    }
}
