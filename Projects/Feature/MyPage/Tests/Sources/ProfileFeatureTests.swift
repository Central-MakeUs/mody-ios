//
//  ProfileFeatureTests.swift
//  MyPageTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import ComposableArchitecture
import CoreCameraInterface
import CoreModyImageInterface
import MyPageInterface
import UIKit
import XCTest
@testable import MyPage

@MainActor
final class ProfileFeatureTests: XCTestCase {
    func testFetchPopulatesOriginalStateAndFailureShowsError() async {
        for fails in [false, true] {
            let repository = MyPageRepositorySpy()
            if fails { repository.profileResult = .failure(NetworkError.networkUnavailable) }
            let store = makeStore(repository: repository)
            await store.send(.onAppear).finish()
            XCTAssertFalse(store.isLoading)
            XCTAssertEqual(repository.profileFetchCount, 1)
            if fails {
                XCTAssertEqual(store.alertCase, .error(.networkUnavailable))
                XCTAssertTrue(store.alertState.isPresented)
            } else {
                XCTAssertEqual(store.name, "모디")
                XCTAssertEqual(store.birthDate, "2000-01-02")
                XCTAssertEqual(store.socialLoginType, .kakao)
                XCTAssertFalse(store.hasUnsavedChanges)
            }
        }
    }

    func testSaveWithoutPhotoForwardsRequestAndOutputThenBack() async {
        let repository = MyPageRepositorySpy()
        let image = MyPageImageSpy()
        var events: [String] = []
        let store = makeStore(state: validState(), repository: repository, image: image,
            router: { if $0 == .back { events.append("back") } },
            output: { if $0 == .profileUpdated { events.append("updated") } })
        await store.send(.saveButtonTapped).finish()
        XCTAssertEqual(repository.profileRequests, [.init(nickname: "모디", birthDate: "2000-01-02")])
        XCTAssertTrue(image.uploads.isEmpty)
        XCTAssertEqual(events, ["updated", "back"])
        XCTAssertFalse(store.isLoading)
    }

    func testPhotoUploadSuccessPassesKeyAndCleansFile() async {
        let image = MyPageImageSpy()
        let repository = MyPageRepositorySpy()
        var state = validState()
        let photo = makePhoto("selected.jpg")
        state.selectedPhoto = photo
        let store = makeStore(state: state, repository: repository, image: image)
        await store.send(.saveButtonTapped).finish()
        XCTAssertEqual(image.uploads.count, 1)
        XCTAssertEqual(image.uploads.first?.url, photo.originalFile.fileURL)
        XCTAssertEqual(image.uploads.first?.name, "selected.jpg")
        XCTAssertEqual(image.uploads.first?.domain, .profile)
        XCTAssertEqual(repository.profileRequests.first?.imageKey, "profile/uploaded-key")
        XCTAssertEqual(image.removedURLs, [photo.originalFile.fileURL])
        XCTAssertNil(store.selectedPhoto)
    }

    func testUploadAndSaveFailuresRetainPhotoWithoutRouting() async {
        for uploadFails in [true, false] {
            let image = MyPageImageSpy()
            let repository = MyPageRepositorySpy()
            if uploadFails { image.uploadError = NetworkError.networkUnavailable }
            else { repository.updateResult = .failure(NetworkError.networkUnavailable) }
            var state = validState()
            state.selectedPhoto = makePhoto("selected.jpg")
            var routes: [MyPageProfileRoute] = []
            var outputs: [MyPageOutput] = []
            let store = makeStore(state: state, repository: repository, image: image,
                router: { routes.append($0) }, output: { outputs.append($0) })
            await store.send(.saveButtonTapped).finish()
            XCTAssertEqual(repository.profileRequests.count, uploadFails ? 0 : 1)
            XCTAssertEqual(store.alertCase, .error(.networkUnavailable))
            XCTAssertFalse(store.isLoading)
            XCTAssertNotNil(store.selectedPhoto)
            XCTAssertTrue(image.removedURLs.isEmpty)
            XCTAssertTrue(routes.isEmpty)
            XCTAssertTrue(outputs.isEmpty)
        }
    }

    func testInvalidInputOrLoadingDoesNotSave() async {
        for condition in 0..<4 {
            var state = validState()
            switch condition {
            case 0: state.name = ""
            case 1: state.name = String(repeating: "가", count: 15)
            case 2: state.birthDate = ""
            default: state.isLoading = true
            }
            let repository = MyPageRepositorySpy()
            let store = makeStore(state: state, repository: repository)
            await store.send(.saveButtonTapped).finish()
            XCTAssertTrue(repository.profileRequests.isEmpty)
        }
    }

    func testUnsavedChangesRequireDiscardAndCleanSelectedPhoto() async {
        var state = validState()
        state.originalState = .init(name: "원래 이름", profileImageURL: nil)
        let photo = makePhoto("discard.jpg")
        state.selectedPhoto = photo
        let image = MyPageImageSpy()
        var routes: [MyPageProfileRoute] = []
        let store = makeStore(state: state, image: image, router: { routes.append($0) })
        await store.send(.backButtonTapped).finish()
        XCTAssertEqual(store.alertCase, .unsavedChanges)
        XCTAssertTrue(routes.isEmpty)
        await store.send(.continueEditingButtonTapped).finish()
        XCTAssertNotNil(store.selectedPhoto)
        XCTAssertTrue(routes.isEmpty)
        await store.send(.discardChangesButtonTapped).finish()
        XCTAssertEqual(routes, [.back])
        XCTAssertEqual(image.removedURLs, [photo.originalFile.fileURL])
        XCTAssertNil(store.selectedPhoto)
    }

    func testPhotoReplacementCleansPreviousFileAndCancellationResetsPresentation() async {
        let image = MyPageImageSpy()
        var state = validState()
        let first = makePhoto("first.jpg")
        let second = makePhoto("second.jpg")
        state.selectedPhoto = first
        let store = makeStore(state: state, image: image)
        await store.send(.gallerySourceTapped).finish()
        XCTAssertTrue(store.isCameraPresented)
        XCTAssertEqual(store.photoCaptureSource, .photoLibrary)
        await store.send(.photoCaptureCompleted(second)).finish()
        XCTAssertEqual(image.removedURLs, [first.originalFile.fileURL])
        XCTAssertEqual(store.selectedPhoto?.originalFile.fileURL, second.originalFile.fileURL)
        XCTAssertFalse(store.isCameraPresented)
        await store.send(.cameraSourceTapped).finish()
        await store.send(.photoCaptureCancelled).finish()
        XCTAssertFalse(store.isCameraPresented)
        XCTAssertNil(store.photoCaptureSource)
        XCTAssertEqual(store.selectedPhoto?.originalFile.fileURL, second.originalFile.fileURL)
    }

    func testLogoutSuccessAndFailure() async {
        for fails in [false, true] {
            let auth = MyPageAuthSpy()
            auth.error = fails ? NetworkError.networkUnavailable : nil
            var routes: [MyPageProfileRoute] = []
            let store = makeStore(auth: auth, router: { routes.append($0) })
            await store.send(.logoutButtonTapped).finish()
            XCTAssertEqual(auth.logoutCount, 1)
            XCTAssertFalse(store.isLoading)
            XCTAssertEqual(routes, fails ? [] : [.routeToSignIn])
            XCTAssertEqual(store.alertCase, fails ? .error(.networkUnavailable) : nil)
        }
    }

    func testDeleteRequiresConfirmationAndCompletionBeforeRouting() async {
        let auth = MyPageAuthSpy()
        var routes: [MyPageProfileRoute] = []
        let store = makeStore(auth: auth, router: { routes.append($0) })
        await store.send(.deleteAccountButtonTapped).finish()
        XCTAssertEqual(store.alertCase, .deleteConfirmation)
        XCTAssertEqual(auth.deleteCount, 0)
        await store.send(.deleteAccountConfirmButtonTapped).finish()
        XCTAssertEqual(auth.deleteCount, 1)
        XCTAssertEqual(store.alertCase, .deleteCompleted)
        XCTAssertFalse(store.alertState.dismissOnScrimTap)
        XCTAssertFalse(store.isLoading)
        XCTAssertTrue(routes.isEmpty)
        await store.send(.deleteAccountCompletionButtonTapped).finish()
        XCTAssertEqual(routes, [.routeToSignIn])
    }

    func testDeleteFailureAndLoadingGuards() async {
        let auth = MyPageAuthSpy()
        auth.error = NetworkError.networkUnavailable
        var routes: [MyPageProfileRoute] = []
        let store = makeStore(auth: auth, router: { routes.append($0) })
        await store.send(.deleteAccountConfirmButtonTapped).finish()
        XCTAssertEqual(store.alertCase, .error(.networkUnavailable))
        XCTAssertEqual(auth.deleteCount, 1)
        XCTAssertTrue(routes.isEmpty)
        var state = validState()
        state.isLoading = true
        let loadingStore = makeStore(state: state, auth: auth)
        await loadingStore.send(.logoutButtonTapped).finish()
        await loadingStore.send(.deleteAccountConfirmButtonTapped).finish()
        XCTAssertEqual(auth.logoutCount, 0)
        XCTAssertEqual(auth.deleteCount, 1)
    }

    private func validState() -> ProfileFeature.State {
        var state = ProfileFeature.State(profileImageURL: nil, defaultAvatar: .poutBlack)
        state.name = "모디"
        state.birthDate = "2000-01-02"
        return state
    }

    private func makePhoto(_ name: String) -> CameraCaptureResult {
        CameraCaptureResult(originalFile: .init(fileURL: URL(fileURLWithPath: "/tmp/\(name)"),
            fileName: name, contentType: "image/jpeg"), croppedPreviewImage: UIImage(),
            normalizedSelectionFrame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    private func makeStore(
        state: ProfileFeature.State = .init(profileImageURL: nil, defaultAvatar: .poutBlack),
        auth: MyPageAuthSpy = .init(), repository: MyPageRepositorySpy = .init(), image: MyPageImageSpy = .init(),
        router: @escaping @MainActor (MyPageProfileRoute) -> Void = { _ in },
        output: @escaping @MainActor (MyPageOutput) -> Void = { _ in }
    ) -> StoreOf<ProfileFeature> {
        Store(initialState: state) {
            ProfileFeature(authUseCase: auth, myPageUseCase: .init(myPageRepository: repository),
                imageUploadUseCase: image, temporaryImageFileUseCase: image, router: router, output: output)
        }
    }
}
