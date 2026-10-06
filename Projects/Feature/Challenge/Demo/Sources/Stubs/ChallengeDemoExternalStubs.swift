//
//  ChallengeDemoExternalStubs.swift
//  ChallengeDemo
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import CoreAuthInterface
import CoreCameraInterface
import CoreHealthInterface
import CoreModyImage
import CoreModyImageInterface
import DesignSystem
import Foundation
import SwiftUI
import UIKit

struct ChallengeDemoAuthStub: AuthUseCaseProtocol {
    private let scenario: ChallengeDemoScenario

    init(scenario: ChallengeDemoScenario) { self.scenario = scenario }

    func signIn(loginType: SocialLoginType, accessToken: String) async throws -> AuthSession {
        try await Task.sleep(for: .milliseconds(500))
        throw CancellationError()
    }

    func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .authFailure { throw NetworkError.networkUnavailable }
        return UserInfo(
            memberId: 1, nickname: "동준", profileImageUrl: nil, daysTogether: 24,
            personalInfoCompleted: true, groupOnboardingCompleted: true, mainAccessible: true
        )
    }

    func logout() async throws {
        try await Task.sleep(for: .milliseconds(500))
    }

    func deleteAccount() async throws {
        try await Task.sleep(for: .milliseconds(500))
    }
}

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

private enum ChallengeDemoProofImage {
    static func load() -> UIImage? {
        guard let url = Bundle.main.url(forResource: "ChallengeDemoDongjun", withExtension: "png") else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }
}

struct ChallengeDemoCameraStub: CameraCaptureBuildable {
    @MainActor
    func makeCameraViewController(
        source: CameraCaptureSource,
        isCropEnabled: Bool,
        cropAspectRatio: CGSize?,
        onEvent: @escaping (CameraCaptureEvent) -> Void,
        onComplete: @escaping (CameraCaptureResult) -> Void,
        onCancel: @escaping () -> Void
    ) -> UIViewController {
        UIHostingController(rootView: VStack {
            Spacer()
            MButton("데모 사진 선택") {
                onComplete(CameraCaptureResult(
                    originalFile: TemporaryImageFile(
                        fileURL: URL(fileURLWithPath: "/tmp/challenge-demo-proof.jpg"),
                        fileName: "challenge-demo-proof.jpg", contentType: "image/jpeg"
                    ),
                    croppedPreviewImage: ChallengeDemoProofImage.load() ?? UIImage(),
                    normalizedSelectionFrame: CGRect(x: 0, y: 0, width: 1, height: 1)
                ))
            }
            .padding(24)
            MButton("데모 촬영 취소", action: onCancel)
                .padding(24)
        })
    }
}
