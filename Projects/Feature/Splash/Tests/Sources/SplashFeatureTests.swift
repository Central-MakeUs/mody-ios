//
//  SplashFeatureTests.swift
//  SplashTests
//
//  Created by 김동준 on 9/29/26.
//

import ComposableArchitecture
import SplashInterface
import SplashTesting
import XCTest
@testable import Splash

@MainActor
final class SplashFeatureTests: XCTestCase {
    func testForceUpdateTakesPriorityAndPresentsAlert() async {
        let repository = SplashRepositorySpy(
            remoteConfigBools: [.forceUpdate: true],
            remoteConfigStrings: [.appStoreURL: "https://apps.apple.com/kr/"]
        )
        let store = makeStore(repository: repository)

        await store.send(.checkForceUpdate) {
            $0.appStoreURLString = "https://apps.apple.com/kr/"
        }
        await store.receive(\.showAlert, .forceUpdate) {
            $0.isLoading = false
            $0.alertCase = .forceUpdate
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        XCTAssertFalse(store.state.isLoading)
        XCTAssertEqual(store.state.appStoreURLString, "https://apps.apple.com/kr/")
        XCTAssertEqual(store.state.alertCase, .forceUpdate)
    }

    func testEmptyNoticeContinuesToHealthCheck() async {
        let repository = SplashRepositorySpy(
            notice: NoticePopupInfo()
        )
        let router = SplashRouterSpy()
        let store = makeStore(repository: repository, router: router)
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.checkNotice).finish()

        XCTAssertEqual(repository.healthCheckCallCount, 1)
        XCTAssertEqual(router.routes, [.routeToMain])
    }

    func testUnstableServerPresentsNetworkError() async {
        let store = makeStore()

        await store.send(.serverHealthChecked(false))
        await store.receive(\.showAlert, .error(.unknown)) {
            $0.isLoading = false
            $0.alertCase = .error(.unknown)
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        XCTAssertFalse(store.state.isLoading)
        XCTAssertEqual(store.state.alertCase, .error(.unknown))
    }

    func testSkippableNoticeContinuesStartupFlow() async {
        let repository = SplashRepositorySpy()
        let router = SplashRouterSpy()
        var state = SplashFeature.State()
        state.alertCase = .notice(
            NoticePopupInfo(
                title: "공지",
                contents: "내용",
                skipPossible: true
            )
        )
        let store = makeStore(
            initialState: state,
            repository: repository,
            router: router
        )
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.noticeConfirmButtonTapped).finish()

        XCTAssertEqual(repository.healthCheckCallCount, 1)
        XCTAssertEqual(router.routes, [.routeToMain])
    }

    func testBlockingNoticeDoesNotContinueStartupFlow() async {
        let repository = SplashRepositorySpy()
        var state = SplashFeature.State()
        state.alertCase = .notice(
            NoticePopupInfo(
                title: "공지",
                contents: "내용",
                skipPossible: false
            )
        )
        let store = makeStore(initialState: state, repository: repository)

        await store.send(.noticeConfirmButtonTapped)

        XCTAssertEqual(repository.healthCheckCallCount, 0)
    }

    func testUserInfoFailureRoutesToSignIn() async {
        let router = SplashRouterSpy()
        let store = makeStore(router: router)

        await store.send(.userInfoFetchFailed) {
            $0.isLoading = false
        }.finish()

        XCTAssertEqual(router.routes, [.routeToSignIn])
    }

    func testUserInfoRoutesByCompletionState() async {
        let cases: [(personal: Bool, group: Bool, main: Bool, route: SplashRoute)] = [
            (false, false, false, .routeToOnBoarding),
            (true, false, false, .routeToModyGroup(showSignUpDoneContents: true)),
            (true, true, false, .routeToModyGroup(showSignUpDoneContents: false)),
            (true, true, true, .routeToMain)
        ]

        for testCase in cases {
            let router = SplashRouterSpy()
            let store = makeStore(router: router)
            let userInfo = SplashUserInfoFixture.make(
                memberID: 42,
                nickname: "테스터",
                personalInfoCompleted: testCase.personal,
                groupOnboardingCompleted: testCase.group,
                mainAccessible: testCase.main
            )

            await store.send(.userInfoFetched(userInfo)) {
                $0.isLoading = false
            }.finish()

            XCTAssertEqual(router.routes, [testCase.route])
        }
    }

    private func makeStore(
        initialState: SplashFeature.State = SplashFeature.State(),
        repository: SplashRepositoryProtocol = SplashRepositorySpy(),
        router: SplashRouterSpy? = nil
    ) -> TestStoreOf<SplashFeature> {
        let router = router ?? SplashRouterSpy()
        return TestStore(initialState: initialState) {
            SplashFeature(
                splashUseCase: SplashUseCase(splashRepository: repository),
                authUseCase: SplashAuthUseCaseStub(
                    userInfoResult: .success(SplashUserInfoFixture.make())
                ),
                router: router.route
            )
        }
    }
}
