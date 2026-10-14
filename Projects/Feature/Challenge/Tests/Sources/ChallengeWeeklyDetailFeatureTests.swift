//  ChallengeWeeklyDetailFeatureTests.swift
//  ChallengeTests
//
//  Created by 김동준 on 10/6/26.
//

import ChallengeInterface
import CommonDomain
import ComposableArchitecture
import CoreAuthInterface
import CoreAuthTesting
import CoreCameraInterface
import CoreModyImageInterface
import Foundation
import UIKit
import XCTest
@testable import Challenge

@MainActor
final class ChallengeWeeklyDetailFeatureTests: XCTestCase {
    func testWeeklyShareRequiresProofAndEmitsImageURL() async {
        let repository = ChallengeFeatureRepositorySpy()
        var outputs: [ChallengeOutput] = []
        let emptyStore = makeWeeklyStore(repository: repository, output: { outputs.append($0) })
        await emptyStore.send(.snsShareButtonTapped)
        let ignoredRequests = await repository.shareRequests
        XCTAssertTrue(ignoredRequests.isEmpty)

        var state = ChallengeWeeklyDetailFeature.State(groupId: 12, challengeId: 7, groupChallengeId: 34)
        state.weeklyChallengeImageInfos = [proof(memberId: 2)]
        let store = makeWeeklyStore(state: state, repository: repository, output: { outputs.append($0) })

        await store.send(.snsShareButtonTapped) { $0.isLoading = true }
        await store.receive(\.weeklyChallengeShareFinished, "https://example.invalid/share.jpg") {
            $0.isLoading = false
        }
        await store.finish()

        XCTAssertEqual(outputs, [.shareWeeklyChallengeImageURL("https://example.invalid/share.jpg")])
        let requests = await repository.shareRequests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first?.groupId, 12)
        XCTAssertEqual(requests.first?.groupChallengeId, 34)
    }

    func testWeeklyInitialLoadUsesMemberAndProofsForAuthenticationState() async {
        let repository = ChallengeFeatureRepositorySpy()
        let store = makeWeeklyStore(
            repository: repository,
            authUseCase: AuthUseCaseStub(userInfoResult: .success(UserInfoFixture.make(nickname: "동준", daysTogether: 10)))
        )
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.onAppear) { $0.isLoading = true }
        await store.receive(\.initialDataFetched)
        await store.finish()

        XCTAssertEqual(store.state.myMemberId, 1)
        XCTAssertEqual(store.state.weeklyChallengeDetail?.title, "걷기")
        XCTAssertEqual(store.state.weeklyChallengeImageInfos, [])
        XCTAssertTrue(store.state.showsAuthenticationItem)
        XCTAssertTrue(store.state.isShareButtonDisabled)
        let detailRequests = await repository.weeklyDetailRequests
        XCTAssertEqual(detailRequests, [7])
        let proofRequests = await repository.proofRequests
        XCTAssertEqual(proofRequests.count, 1)
        XCTAssertEqual(proofRequests.first?.groupId, 12)
        XCTAssertEqual(proofRequests.first?.groupChallengeId, 34)

        let ownProof = proof(memberId: 1)
        await store.send(.initialDataFetched(
            memberId: 1,
            detail: WeeklyChallengeDetail(challengeId: 7, title: "걷기", description: "함께 걷기", remainingDays: 3),
            imageInfos: [ownProof]
        )) {
            $0.weeklyChallengeImageInfos = [ownProof]
        }
        XCTAssertFalse(store.state.showsAuthenticationItem)
        XCTAssertFalse(store.state.isShareButtonDisabled)
    }

    func testWeeklyShareIncompleteErrorShowsSpecificAlert() async {
        let repository = ChallengeFeatureRepositorySpy()
        await repository.setShareResult(.failure(.serverError(
            code: ServerErrorCode.challenge306.code, message: nil, fallback: .badRequest
        )))
        var state = ChallengeWeeklyDetailFeature.State(groupId: 12, challengeId: 7, groupChallengeId: 34)
        state.weeklyChallengeImageInfos = [proof(memberId: 2)]
        let store = makeWeeklyStore(state: state, repository: repository)
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.snsShareButtonTapped) { $0.isLoading = true }
        await store.receive(\.showAlert, .incompleteChallenge) {
            $0.isLoading = false
            $0.alertCase = .incompleteChallenge
        }
        await store.finish()

        XCTAssertEqual(store.state.alertCase, .incompleteChallenge)
        let shareRequests = await repository.shareRequests
        XCTAssertEqual(shareRequests.count, 1)
    }

    func testWeeklyAuthenticationSourceCanOpenAndCancelCamera() async {
        let repository = ChallengeFeatureRepositorySpy()
        var state = ChallengeWeeklyDetailFeature.State(groupId: 12, challengeId: 7, groupChallengeId: 34)
        state.myMemberId = 1
        state.weeklyChallengeImageInfos = []
        let store = makeWeeklyStore(state: state, repository: repository)

        await store.send(.authenticationButtonTapped) { $0.isPhotoSourceSheetPresented = true }
        await store.send(.gallerySourceTapped) {
            $0.isPhotoSourceSheetPresented = false
            $0.photoCaptureSource = .photoLibrary
            $0.isCameraPresented = true
        }
        await store.send(.photoCaptureCancelled) {
            $0.photoCaptureSource = nil
            $0.isCameraPresented = false
        }
        await store.send(.cameraSourceTapped) {
            $0.photoCaptureSource = .camera
            $0.isCameraPresented = true
        }
        await store.send(.photoCaptureCancelled) {
            $0.photoCaptureSource = nil
            $0.isCameraPresented = false
        }

        XCTAssertFalse(store.state.isLoading)
    }

    func testWeeklyProofUploadCreatesClampedCropAndRemovesTemporaryFile() async {
        let repository = ChallengeFeatureRepositorySpy()
        let image = ChallengeImageSpy()
        let createdProof = proof(memberId: 1)
        await repository.setProofs([createdProof])
        var outputs: [ChallengeOutput] = []
        var state = ChallengeWeeklyDetailFeature.State(groupId: 12, challengeId: 7, groupChallengeId: 34)
        state.isCameraPresented = true
        state.photoCaptureSource = .photoLibrary
        state.weeklyChallengeImageInfos = []
        let store = makeWeeklyStore(
            state: state, repository: repository, imageUseCase: image,
            output: { outputs.append($0) }
        )
        let result = cameraResult(crop: CGRect(x: -0.2, y: 0.25, width: 1.2, height: 0.5))

        await store.send(.photoCaptureCompleted(result)) {
            $0.isCameraPresented = false
            $0.photoCaptureSource = nil
            $0.isLoading = true
        }
        await store.receive(\.weeklyChallengeProofCreated, [createdProof]) {
            $0.isLoading = false
            $0.weeklyChallengeImageInfos = [createdProof]
        }
        await store.finish()

        XCTAssertEqual(outputs, [.weeklyChallengeProofCreated])
        XCTAssertEqual(image.uploads.count, 1)
        XCTAssertEqual(image.uploads.first?.fileURL, result.originalFile.fileURL)
        XCTAssertEqual(image.uploads.first?.fileName, result.originalFile.fileName)
        XCTAssertEqual(image.uploads.first?.domain, .record)
        XCTAssertEqual(image.removedURLs, [result.originalFile.fileURL])
        let creations = await repository.proofCreations
        let fetches = await repository.proofRequests
        XCTAssertEqual(creations.count, 1)
        XCTAssertEqual(creations.first?.groupId, 12)
        XCTAssertEqual(creations.first?.groupChallengeId, 34)
        XCTAssertEqual(creations.first?.request.imageKey, "uploaded-proof")
        XCTAssertEqual(creations.first?.request.imageCropRegion.x, 0)
        XCTAssertEqual(creations.first?.request.imageCropRegion.y, 0.25)
        XCTAssertEqual(creations.first?.request.imageCropRegion.width, 1)
        XCTAssertEqual(creations.first?.request.imageCropRegion.height, 0.5)
        XCTAssertEqual(fetches.count, 1)
    }

    func testWeeklyProofUploadFailureCleansUpAndShowsError() async {
        let repository = ChallengeFeatureRepositorySpy()
        let image = ChallengeImageSpy(uploadResult: .failure(.networkUnavailable))
        var outputs: [ChallengeOutput] = []
        let store = makeWeeklyStore(
            repository: repository, imageUseCase: image,
            output: { outputs.append($0) }
        )
        store.exhaustivity = .off(showSkippedAssertions: false)
        let result = cameraResult()

        await store.send(.photoCaptureCompleted(result)) { $0.isLoading = true }
        await store.receive(\.showAlert, .error(.networkUnavailable)) {
            $0.isLoading = false
            $0.alertCase = .error(.networkUnavailable)
        }
        await store.finish()

        XCTAssertEqual(image.removedURLs, [result.originalFile.fileURL])
        let creations = await repository.proofCreations
        XCTAssertTrue(creations.isEmpty)
        XCTAssertTrue(outputs.isEmpty)
    }

    func testWeeklyProofCreateFailureCleansUpWithoutRefetch() async {
        let repository = ChallengeFeatureRepositorySpy()
        await repository.setProofCreateError(.serverUnavailable)
        let image = ChallengeImageSpy()
        let store = makeWeeklyStore(repository: repository, imageUseCase: image)
        store.exhaustivity = .off(showSkippedAssertions: false)
        let result = cameraResult()

        await store.send(.photoCaptureCompleted(result)) { $0.isLoading = true }
        await store.receive(\.showAlert, .error(.serverUnavailable)) {
            $0.isLoading = false
            $0.alertCase = .error(.serverUnavailable)
        }
        await store.finish()

        XCTAssertEqual(image.removedURLs, [result.originalFile.fileURL])
        let creations = await repository.proofCreations
        let fetches = await repository.proofRequests
        XCTAssertEqual(creations.count, 1)
        XCTAssertTrue(fetches.isEmpty)
    }

    func testWeeklyInitialLoadFailureShowsErrorWithoutPartialContent() async {
        let repository = ChallengeFeatureRepositorySpy()
        let store = makeWeeklyStore(
            repository: repository,
            authUseCase: AuthUseCaseStub(userInfoResult: .failure(NetworkError.networkUnavailable))
        )
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.onAppear) { $0.isLoading = true }
        await store.receive(\.showAlert, .error(.networkUnavailable)) {
            $0.isLoading = false
            $0.alertCase = .error(.networkUnavailable)
        }
        await store.finish()

        XCTAssertNil(store.state.myMemberId)
        XCTAssertNil(store.state.weeklyChallengeDetail)
        XCTAssertNil(store.state.weeklyChallengeImageInfos)
    }

    func testWeeklyShareNetworkFailureUsesGenericErrorAlert() async {
        let repository = ChallengeFeatureRepositorySpy()
        await repository.setShareResult(.failure(.networkUnavailable))
        var state = ChallengeWeeklyDetailFeature.State(groupId: 12, challengeId: 7, groupChallengeId: 34)
        state.weeklyChallengeImageInfos = [proof(memberId: 2)]
        let store = makeWeeklyStore(state: state, repository: repository)
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.snsShareButtonTapped) { $0.isLoading = true }
        await store.receive(\.showAlert, .error(.networkUnavailable)) {
            $0.isLoading = false
            $0.alertCase = .error(.networkUnavailable)
        }
        await store.finish()

        XCTAssertEqual(store.state.alertCase, .error(.networkUnavailable))
        let requests = await repository.shareRequests
        XCTAssertEqual(requests.count, 1)
    }

    func testWeeklyBackButtonRoutesBack() async {
        var routes: [ChallengeWeeklyDetailRoute] = []
        let store = makeWeeklyStore(
            repository: ChallengeFeatureRepositorySpy(),
            router: { routes.append($0) }
        )

        await store.send(.backButtonTapped).finish()

        XCTAssertEqual(routes, [.back])
    }

    private func proof(memberId: Int) -> WeeklyChallengeImageInfo {
        WeeklyChallengeImageInfo(
            proofId: 1, imageUrl: "https://example.invalid/proof.jpg", imageCropRegion: nil,
            memberId: memberId, nickname: "동규", profileImageUrl: nil
        )
    }

    private func cameraResult(crop: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)) -> CameraCaptureResult {
        CameraCaptureResult(
            originalFile: TemporaryImageFile(
                fileURL: URL(fileURLWithPath: "/tmp/challenge-test-proof.jpg"),
                fileName: "challenge-test-proof.jpg", contentType: "image/jpeg"
            ),
            croppedPreviewImage: UIImage(),
            normalizedSelectionFrame: crop
        )
    }

    private func makeWeeklyStore(
        state: ChallengeWeeklyDetailFeature.State = .init(groupId: 12, challengeId: 7, groupChallengeId: 34),
        repository: ChallengeFeatureRepositorySpy,
        authUseCase: AuthUseCaseProtocol = AuthUseCaseStub(userInfoResult: .failure(NetworkError.unknown)),
        imageUseCase: ImageUploadUseCaseProtocol & TemporaryImageFileUseCaseProtocol = ChallengeImageDummy(),
        router: @escaping @MainActor (ChallengeWeeklyDetailRoute) -> Void = { _ in },
        output: @escaping @MainActor (ChallengeOutput) -> Void = { _ in }
    ) -> TestStoreOf<ChallengeWeeklyDetailFeature> {
        TestStore(initialState: state) {
            ChallengeWeeklyDetailFeature(
                authUseCase: authUseCase,
                challengeUseCase: ChallengeUseCase(repository: repository),
                imageUploadUseCase: imageUseCase,
                temporaryImageFileUseCase: imageUseCase,
                router: router,
                output: output
            )
        }
    }
}

private struct ChallengeImageDummy: ImageUploadUseCaseProtocol, TemporaryImageFileUseCaseProtocol {
    func uploadImage(fileURL: URL, fileName: String, domain: ImageUploadDomain) async throws -> String {
        XCTFail("Unexpected image upload")
        throw NetworkError.unknown
    }

    func saveImage(data: Data, fileName: String) throws -> TemporaryImageFile {
        XCTFail("Unexpected image save")
        throw NetworkError.unknown
    }

    func copyImage(at sourceURL: URL, fileName: String) throws -> TemporaryImageFile {
        XCTFail("Unexpected image copy")
        throw NetworkError.unknown
    }

    func removeImage(at fileURL: URL) throws { XCTFail("Unexpected image removal") }
    func removeExpiredImages(olderThan expirationInterval: TimeInterval) throws {
        XCTFail("Unexpected image cleanup")
    }
}
