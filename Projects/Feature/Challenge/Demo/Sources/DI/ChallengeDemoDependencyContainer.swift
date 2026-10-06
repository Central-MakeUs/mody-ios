//
//  ChallengeDemoDependencyContainer.swift
//  ChallengeDemo
//
//  Created by 김동준 on 10/5/26.
//

import Challenge
import ChallengeInterface
import ChallengeTesting
import CommonDomain

@MainActor
final class ChallengeDemoDependencyContainer {
    func makeBuilder(for scenario: ChallengeDemoScenario, data: ChallengeDemoData) -> ChallengeBuildable {
        let challengeUseCase = ChallengeUseCase(
            repository: ChallengeDemoRepositoryStub(scenario: scenario, data: data)
        )
        let userInfo = UserInfo(
            memberId: 1, nickname: "동준", profileImageUrl: nil, daysTogether: 24,
            personalInfoCompleted: true, groupOnboardingCompleted: true, mainAccessible: true
        )
        let authUseCase = ChallengeAuthUseCaseStub(
            userInfoResult: scenario == .authFailure ? .failure(.networkUnavailable) : .success(userInfo),
            responseDelay: .milliseconds(500)
        )
        let imageUseCase = ChallengeDemoImageStub(scenario: scenario)

        return ChallengeBuilder(
            makeChallengeFeature: { router, output in
                ChallengeFeature(
                    challengeUseCase: challengeUseCase,
                    healthUseCase: ChallengeDemoHealthStub(scenario: scenario, data: data),
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
                    imageUploadUseCase: imageUseCase,
                    temporaryImageFileUseCase: imageUseCase,
                    router: { [weak router] in router?.route(from: $0) },
                    output: { [weak output] in output?.handle(output: $0) }
                )
            },
            imageLoader: ChallengeDemoImageLoader(),
            cameraCaptureBuilder: ChallengeDemoCameraStub()
        )
    }
}
