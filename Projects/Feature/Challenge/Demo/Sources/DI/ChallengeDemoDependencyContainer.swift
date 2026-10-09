//
//  ChallengeDemoDependencyContainer.swift
//  ChallengeDemo
//
//  Created by 김동준 on 10/5/26.
//

import Challenge
import ChallengeInterface
import CommonDomain
import CoreAuthTesting
import CoreCameraTesting
import CoreHealthTesting
import CoreModyImage
import CoreModyImageInterface
import CoreModyImageTesting
import UIKit

@MainActor
final class ChallengeDemoDependencyContainer {
    func makeBuilder(for scenario: ChallengeDemoScenario, data: ChallengeDemoData) -> ChallengeBuildable {
        let challengeUseCase = ChallengeUseCase(
            repository: ChallengeDemoRepositoryStub(scenario: scenario, data: data)
        )
        let userInfo = UserInfoFixture.make(nickname: "동준", daysTogether: 24)
        let authUseCase = AuthUseCaseStub(
            userInfoResult: scenario == .authFailure ? .failure(NetworkError.networkUnavailable) : .success(userInfo),
            responseDelay: .milliseconds(500)
        )
        let imageUpload = ImageUploadUseCaseStub(
            result: scenario == .weeklyUploadFailure
                ? .failure(NetworkError.networkUnavailable) : .success("challenge-demo-proof"),
            responseDelay: .milliseconds(500)
        )
        let temporaryFiles = TemporaryImageFileUseCaseStub.metadataOnly()
        let imageLoader = NukeRemoteImageLoader()
        let remoteImages = RemoteImageLoaderStub(loadImage: { request in
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
                url: url, variantIdentifier: request.variantIdentifier,
                maximumPixelSize: request.maximumPixelSize, processing: request.processing
            ))
        }, responseDelay: .milliseconds(500))
        let healthUseCase = HealthUseCaseStub(
            getStepCount: { _, _ in
                if scenario == .stepCompetition || scenario == .stepLive {
                    return await data.simulatedSelfStepCount(for: scenario)
                }
                return 3_400
            },
            getCurrentMonthStepCount: { 42_000 },
            responseDelay: .milliseconds(500)
        )

        return ChallengeBuilder(
            makeChallengeFeature: { router, output in
                ChallengeFeature(
                    challengeUseCase: challengeUseCase,
                    healthUseCase: healthUseCase,
                    router: { [weak router] in router?.route(from: $0) },
                    output: { [weak output] in output?.handle(output: $0) }
                )
            },
            makeChallengeChangeFeature: { router, output in
                ChallengeChangeFeature(
                    challengeUseCase: challengeUseCase,
                    router: { [weak router] in router?.route(from: $0) },
                    output: { [weak output] in output?.handle(output: $0) }
                )
            },
            makeChallengeWeeklyDetailFeature: { router, output in
                ChallengeWeeklyDetailFeature(
                    authUseCase: authUseCase,
                    challengeUseCase: challengeUseCase,
                    imageUploadUseCase: imageUpload,
                    temporaryImageFileUseCase: temporaryFiles,
                    router: { [weak router] in router?.route(from: $0) },
                    output: { [weak output] in output?.handle(output: $0) }
                )
            },
            imageLoader: remoteImages,
            cameraCaptureBuilder: CameraCaptureBuilderStub {
                let image = Bundle.main.url(forResource: "ChallengeDemoDongjun", withExtension: "png")
                    .flatMap { UIImage(contentsOfFile: $0.path) } ?? UIImage()
                return CameraCaptureResultFixture.make(
                    previewImage: image,
                    fileName: "challenge-demo-proof.jpg"
                )
            }
        )
    }
}
