//
//  FeedRecordReactorTests.swift
//  FeedTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import CoreCameraInterface
import CoreModyImageInterface
import Foundation
import FeedInterface
import UIKit
import XCTest
@testable import Feed

@MainActor
final class FeedRecordReactorTests: XCTestCase {
    func testMealRequiresPhotoAndNonblankMenuAndDisablesFinishWhileSubmitting() {
        let reactor = makeReactor(recordType: .meal)
        var state = reactor.initialState

        state = reactor.reduce(state: state, mutation: .setMealMenu("  비빔밥  "))
        XCTAssertFalse(state.isFinishButtonEnabled)

        state = reactor.reduce(state: state, mutation: .completePhotoCapture(photo()))
        XCTAssertTrue(state.isFinishButtonEnabled)

        state = reactor.reduce(state: state, mutation: .setMealMenu(" \n "))
        XCTAssertFalse(state.isFinishButtonEnabled)

        state = reactor.reduce(state: state, mutation: .setMealMenu("비빔밥"))
        state = reactor.reduce(state: state, mutation: .setSubmittingRecord(true))
        XCTAssertFalse(state.isFinishButtonEnabled)
    }

    func testExerciseRequiresTypeNameAndPositiveDuration() {
        let reactor = makeReactor(recordType: .exercise)
        var state = reactor.reduce(state: reactor.initialState, mutation: .completePhotoCapture(photo()))
        state = reactor.reduce(state: state, mutation: .setExerciseType(.custom))
        XCTAssertFalse(state.isFinishButtonEnabled)

        state = reactor.reduce(state: state, mutation: .setCustomExerciseName("클라이밍"))
        XCTAssertTrue(state.isFinishButtonEnabled)

        state = reactor.reduce(state: state, mutation: .setExerciseDuration(hours: 0, minutes: 0))
        XCTAssertFalse(state.isFinishButtonEnabled)

        state = reactor.reduce(state: state, mutation: .setExerciseType(.running))
        state = reactor.reduce(state: state, mutation: .setExerciseDuration(hours: 0, minutes: 15))
        XCTAssertTrue(state.isFinishButtonEnabled)
    }

    func testSuccessfulSubmitUploadsOriginalCreatesRecordAndRemovesTemporaryFile() async {
        let repository = FeedRepositorySpy()
        let upload = FeedImageUploadSpy()
        let files = FeedTemporaryImageFileSpy()
        let created = expectation(description: "recordCreated output")
        let reactor = makeReactor(
            recordType: .meal, repository: repository, upload: upload, files: files
        ) { output in
            XCTAssertEqual(output, .recordCreated)
            created.fulfill()
        }
        let disposable = reactor.state.subscribe()
        defer { disposable.dispose() }
        let capture = photo()

        reactor.action.onNext(.didChangeMealMenu("  비빔밥  "))
        reactor.action.onNext(.didCompletePhotoCapture(capture))
        reactor.action.onNext(.didTapFinishButton)
        await fulfillment(of: [created], timeout: 2)

        XCTAssertEqual(upload.fileURLs, [capture.originalFile.fileURL])
        XCTAssertEqual(upload.domains, [.record])
        XCTAssertEqual(repository.createdRecords.count, 1)
        XCTAssertEqual(repository.createdRecords.first?.imageKey, "uploaded-image-key")
        XCTAssertEqual(repository.createdRecords.first?.menu, "비빔밥")
        XCTAssertEqual(files.removedURLs, [capture.originalFile.fileURL])
    }

    func testUploadFailureShowsErrorAndDoesNotCreateRecord() async {
        let repository = FeedRepositorySpy()
        let upload = FeedImageUploadSpy()
        upload.result = .failure(NetworkError.timeout)
        let files = FeedTemporaryImageFileSpy()
        let failed = expectation(description: "failure alert")
        let reactor = makeReactor(
            recordType: .meal, repository: repository, upload: upload, files: files
        ) { _ in XCTFail("Unexpected record output") }
        let disposable = reactor.state.subscribe(onNext: { state in
            if state.recordFailureAlert == .timeout { failed.fulfill() }
        })
        defer { disposable.dispose() }

        reactor.action.onNext(.didChangeMealMenu("비빔밥"))
        reactor.action.onNext(.didCompletePhotoCapture(photo()))
        reactor.action.onNext(.didTapFinishButton)
        await fulfillment(of: [failed], timeout: 2)

        XCTAssertTrue(repository.createdRecords.isEmpty)
        XCTAssertFalse(reactor.currentState.isSubmittingRecord)
        XCTAssertTrue(files.removedURLs.isEmpty)
    }

    private func makeReactor(
        recordType: FeedRecordType,
        repository: FeedRepositorySpy = FeedRepositorySpy(),
        upload: FeedImageUploadSpy = FeedImageUploadSpy(),
        files: FeedTemporaryImageFileSpy = FeedTemporaryImageFileSpy(),
        output: @escaping @MainActor (FeedRecordOutput) -> Void = { _ in }
    ) -> FeedRecordReactor {
        FeedRecordReactor(
            router: FeedRecordRouterSpy(), recordType: recordType,
            feedUseCase: FeedUseCase(feedRepository: repository),
            imageUploadUseCase: upload, temporaryImageFileUseCase: files,
            output: output
        )
    }

    private func photo() -> CameraCaptureResult {
        CameraCaptureResult(
            originalFile: TemporaryImageFile(
                fileURL: URL(fileURLWithPath: "/tmp/feed-photo.jpg"),
                fileName: "feed-photo.jpg", contentType: "image/jpeg"
            ),
            croppedPreviewImage: UIImage(),
            normalizedSelectionFrame: CGRect(x: 0, y: 0, width: 1, height: 1)
        )
    }
}
