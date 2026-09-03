//
//  FeedRecordReactorImageLifecycleTests.swift
//  FeedTests
//
//  Created by 김동준 on 7/25/26.
//

import CommonDomain
import CoreCameraInterface
import CoreAnalyticsInterface
import CoreModyImageInterface
import FeedInterface
import RxSwift
import UIKit
import XCTest
@testable import Feed

@MainActor
final class FeedRecordReactorImageLifecycleTests: XCTestCase {
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }

    func testSuccessfulRecordRemovesTemporaryFile() async throws {
        let dependencies = makeDependencies()
        let outputExpectation = expectation(description: "record created output")
        dependencies.output.onRecordCreated = {
            outputExpectation.fulfill()
        }
        let reactor = makeReactor(dependencies: dependencies)
        let captureResult = makeCaptureResult(fileName: "success.jpg")

        selectMealPhoto(captureResult, on: reactor)
        reactor.action.onNext(.didTapFinishButton)

        await fulfillment(of: [outputExpectation], timeout: 1)

        XCTAssertEqual(dependencies.imageUpload.uploadCallCount, 1)
        XCTAssertEqual(dependencies.feedRepository.createRecordCallCount, 1)
        XCTAssertEqual(
            dependencies.temporaryFiles.removedFileURLs,
            [captureResult.originalFile.fileURL]
        )
    }

    func testRecordRetryUploadsImageAgain() async throws {
        let dependencies = makeDependencies()
        dependencies.feedRepository.createRecordError = NetworkError.invalidResponse
        let failureExpectation = expectation(description: "record failure state")
        let outputExpectation = expectation(description: "record retry succeeded")
        dependencies.output.onRecordCreated = {
            outputExpectation.fulfill()
        }
        let reactor = makeReactor(dependencies: dependencies)
        let captureResult = makeCaptureResult(fileName: "retry.jpg")

        reactor.state
            .filter { $0.recordFailureAlert != nil }
            .take(1)
            .subscribe(onNext: { _ in
                failureExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        selectMealPhoto(captureResult, on: reactor)
        reactor.action.onNext(.didTapFinishButton)
        await fulfillment(of: [failureExpectation], timeout: 1)

        XCTAssertEqual(dependencies.imageUpload.uploadCallCount, 1)
        XCTAssertTrue(dependencies.temporaryFiles.removedFileURLs.isEmpty)

        dependencies.feedRepository.createRecordError = nil
        reactor.action.onNext(.didDismissRecordFailureAlert)
        reactor.action.onNext(.didTapFinishButton)
        await fulfillment(of: [outputExpectation], timeout: 1)

        XCTAssertEqual(dependencies.imageUpload.uploadCallCount, 2)
        XCTAssertEqual(dependencies.feedRepository.createRecordCallCount, 2)
        XCTAssertEqual(
            dependencies.temporaryFiles.removedFileURLs,
            [captureResult.originalFile.fileURL]
        )
    }

    func testReplacingPhotoRemovesPreviousTemporaryFile() {
        let dependencies = makeDependencies()
        let reactor = makeReactor(dependencies: dependencies)
        let firstCaptureResult = makeCaptureResult(fileName: "first.jpg")
        let secondCaptureResult = makeCaptureResult(fileName: "second.jpg")

        reactor.action.onNext(.didCompletePhotoCapture(firstCaptureResult))
        reactor.action.onNext(.didCompletePhotoCapture(secondCaptureResult))

        XCTAssertEqual(
            dependencies.temporaryFiles.removedFileURLs,
            [firstCaptureResult.originalFile.fileURL]
        )
        XCTAssertEqual(
            reactor.currentState.selectedPhoto?.originalFile,
            secondCaptureResult.originalFile
        )
    }

    func testBackRemovesSelectedTemporaryFile() async {
        let dependencies = makeDependencies()
        let routeExpectation = expectation(description: "route back")
        dependencies.router.onRoute = { route in
            guard route == .back else { return }
            routeExpectation.fulfill()
        }
        let reactor = makeReactor(dependencies: dependencies)
        let captureResult = makeCaptureResult(fileName: "cancel.jpg")

        reactor.action.onNext(.didCompletePhotoCapture(captureResult))
        reactor.action.onNext(.didTapBackButton)
        await fulfillment(of: [routeExpectation], timeout: 1)

        XCTAssertEqual(
            dependencies.temporaryFiles.removedFileURLs,
            [captureResult.originalFile.fileURL]
        )
        XCTAssertEqual(dependencies.router.routes, [.back])
    }
}

private extension FeedRecordReactorImageLifecycleTests {
    @MainActor
    struct Dependencies {
        let router = FeedRecordRouterMock()
        let feedRepository = FeedRepositoryMock()
        let imageUpload = ImageUploadUseCaseMock()
        let temporaryFiles = TemporaryImageFileUseCaseMock()
        let output = FeedRecordOutputHandlerMock()
    }

    func makeDependencies() -> Dependencies {
        Dependencies()
    }

    func makeReactor(dependencies: Dependencies) -> FeedRecordReactor {
        FeedRecordReactor(
            router: dependencies.router,
            recordType: .meal,
            feedUseCase: FeedUseCase(feedRepository: dependencies.feedRepository),
            imageUploadUseCase: dependencies.imageUpload,
            temporaryImageFileUseCase: dependencies.temporaryFiles,
            analyticsUseCase: FeedRecordAnalyticsUseCaseMock(),
            output: { [weak output = dependencies.output] event in
                output?.handle(output: event)
            }
        )
    }

    func selectMealPhoto(
        _ captureResult: CameraCaptureResult,
        on reactor: FeedRecordReactor
    ) {
        reactor.action.onNext(.didCompletePhotoCapture(captureResult))
        reactor.action.onNext(.didChangeMealMenu("샐러드"))
    }

    func makeCaptureResult(fileName: String) -> CameraCaptureResult {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
        let temporaryFile = TemporaryImageFile(
            fileURL: fileURL,
            fileName: fileName,
            contentType: "image/jpeg"
        )
        return CameraCaptureResult(
            originalFile: temporaryFile,
            croppedPreviewImage: UIImage(),
            normalizedSelectionFrame: CGRect(x: 0, y: 0, width: 1, height: 1)
        )
    }
}

private struct FeedRecordAnalyticsUseCaseMock: AnalyticsUseCaseProtocol {
    func setUserID(_ userID: String) {}
    func setUserNickname(_ nickname: String) {}
    func reset() {}
    func log(_ event: AmplitudeLogEvent) {}
    func viewDidLoad(screenName: String) {}
}

@MainActor
private final class FeedRecordRouterMock: FeedRecordRouter {
    private(set) var routes: [FeedRecordRoute] = []
    var onRoute: ((FeedRecordRoute) -> Void)?

    func route(from route: FeedRecordRoute) {
        routes.append(route)
        onRoute?(route)
    }
}

private final class FeedRepositoryMock: FeedRepositoryProtocol {
    var createRecordError: Error?
    private(set) var createRecordCallCount = 0

    func getRecords(
        groupId: Int,
        date: String,
        cursor: Int?,
        size: Int
    ) async throws -> FeedRecordPage {
        fatalError("Not used in these tests")
    }

    func getActivityCalendar(
        groupId: Int,
        baseDate: String
    ) async throws -> FeedActivityCalendarModel {
        fatalError("Not used in these tests")
    }

    func postRecord(_ request: FeedRecordCreateRequest) async throws {
        createRecordCallCount += 1
        if let createRecordError {
            throw createRecordError
        }
    }

    func postRecordReport(groupId: Int, recordId: Int) async throws {}

    func deleteRecord(recordId: Int) async throws {}
}

private final class ImageUploadUseCaseMock: ImageUploadUseCaseProtocol {
    let imageKey = "uploaded-image-key"
    private(set) var uploadCallCount = 0

    func uploadImage(
        fileURL: URL,
        fileName: String,
        domain: ImageUploadDomain
    ) async throws -> String {
        uploadCallCount += 1
        return imageKey
    }
}

private final class TemporaryImageFileUseCaseMock: TemporaryImageFileUseCaseProtocol {
    private(set) var removedFileURLs: [URL] = []

    func saveImage(
        data: Data,
        fileName: String
    ) throws -> TemporaryImageFile {
        fatalError("Not used in these tests")
    }

    func copyImage(
        at sourceURL: URL,
        fileName: String
    ) throws -> TemporaryImageFile {
        fatalError("Not used in these tests")
    }

    func removeImage(at fileURL: URL) throws {
        guard !removedFileURLs.contains(fileURL) else { return }
        removedFileURLs.append(fileURL)
    }

    func removeExpiredImages(olderThan expirationInterval: TimeInterval) throws {}
}

@MainActor
private final class FeedRecordOutputHandlerMock: FeedRecordOutputHandler {
    var onRecordCreated: (() -> Void)?

    func handle(output: FeedRecordOutput) {
        guard output == .recordCreated else { return }
        onRecordCreated?()
    }
}
