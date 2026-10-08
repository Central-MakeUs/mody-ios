//
//  SignInFeatureTests.swift
//  SignInTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import ComposableArchitecture
import CoreAuthInterface
import CoreAuthTesting
import SignInInterface
import XCTest
@testable import SignIn

@MainActor
final class SignInFeatureTests: XCTestCase {
    func testOnAppearReadsDemoLoginAvailability() async {
        for isEnabled in [false, true] {
            let store = makeStore(isDemoLoginEnabled: isEnabled)

            if isEnabled {
                await store.send(.onAppear) {
                    $0.isDemoLoginEnabled = true
                }
            } else {
                await store.send(.onAppear)
            }

            XCTAssertEqual(store.state.isDemoLoginEnabled, isEnabled)
        }
    }

    func testDemoLoginOpensOnlyAtTwentiethTapWhenEnabled() async {
        var state = SignInFeature.State()
        state.isDemoLoginEnabled = true
        state.demoLoginTapCount = 19
        let store = makeStore(initialState: state)

        await store.send(.demoLoginTriggerAreaTapped) {
            $0.demoLoginTapCount = 0
            $0.isDemoLoginAlertPresented = true
        }
    }

    func testDemoLoginTriggerIsIgnoredWhenDisabledOrLoading() async {
        var disabledState = SignInFeature.State()
        disabledState.demoLoginTapCount = 19
        let disabledStore = makeStore(initialState: disabledState)

        await disabledStore.send(.demoLoginTriggerAreaTapped)
        XCTAssertEqual(disabledStore.state.demoLoginTapCount, 19)

        var loadingState = disabledState
        loadingState.isDemoLoginEnabled = true
        loadingState.isLoading = true
        let loadingStore = makeStore(initialState: loadingState)

        await loadingStore.send(.demoLoginTriggerAreaTapped)
        XCTAssertEqual(loadingStore.state.demoLoginTapCount, 19)
    }

    func testWrongDemoPasswordClearsPromptWithoutSigningIn() async {
        var state = SignInFeature.State()
        state.isDemoLoginEnabled = true
        state.isDemoLoginAlertPresented = true
        state.demoLoginPassword = "wrong"
        let router = SignInRouterSpy()
        let store = makeStore(initialState: state, router: router)

        await store.send(.demoLoginConfirmButtonTapped) {
            $0.demoLoginPassword = ""
            $0.isDemoLoginAlertPresented = false
        }

        XCTAssertFalse(store.state.isLoading)
        XCTAssertTrue(router.routes.isEmpty)
    }

    func testDemoLoginSuccessRoutesToMain() async {
        var state = SignInFeature.State()
        state.isDemoLoginEnabled = true
        state.isDemoLoginAlertPresented = true
        state.demoLoginPassword = "77777"
        let router = SignInRouterSpy()
        let auth = SignInAuthUseCaseSpy()
        let store = makeStore(initialState: state, authUseCase: auth, router: router)
        let session = AuthSessionFixture.make()

        await store.send(.demoLoginConfirmButtonTapped) {
            $0.demoLoginPassword = ""
            $0.isDemoLoginAlertPresented = false
            $0.isLoading = true
        }
        await store.receive(\.receiveLoginSessionSuccessfully, session) {
            $0.isLoading = false
            $0.navigationDestination = .routeToMain
        }
        await store.finish()

        XCTAssertEqual(router.routes, [.routeToMain])
        XCTAssertEqual(auth.signInRequests.count, 1)
        XCTAssertEqual(auth.signInRequests.first?.loginType, .iosTest)
        XCTAssertEqual(auth.signInRequests.first?.accessToken, "")
    }

    func testLoginSuccessRoutesBySessionCompletionState() async {
        let cases: [(personal: Bool, group: Bool, main: Bool, route: SignInRoute)] = [
            (false, false, false, .routeToOnBoarding),
            (true, false, false, .routeToModyGroup(showSignUpDoneContents: true)),
            (true, true, false, .routeToModyGroup(showSignUpDoneContents: false)),
            (true, true, true, .routeToMain)
        ]

        for testCase in cases {
            let session = AuthSessionFixture.make(
                personalInfoCompleted: testCase.personal,
                mainAccessible: testCase.main,
                groupOnboardingCompleted: testCase.group
            )
            let router = SignInRouterSpy()
            let store = makeStore(router: router)

            await store.send(.receiveLoginSessionSuccessfully(session)) {
                $0.navigationDestination = testCase.route
            }.finish()

            XCTAssertEqual(router.routes, [testCase.route])
        }
    }

    func testKakaoLoginUsesSocialTokenAndRoutesToMain() async {
        let router = SignInRouterSpy()
        let auth = SignInAuthUseCaseSpy()
        let store = makeStore(authUseCase: auth, router: router)
        let session = AuthSessionFixture.make()

        await store.send(.kakaoLoginButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.receiveLoginSessionSuccessfully, session) {
            $0.isLoading = false
            $0.navigationDestination = .routeToMain
        }
        await store.finish()

        XCTAssertEqual(router.routes, [.routeToMain])
        XCTAssertEqual(auth.signInRequests.count, 1)
        XCTAssertEqual(auth.signInRequests.first?.loginType, .kakao)
        XCTAssertEqual(auth.signInRequests.first?.accessToken, "social-token")
    }

    func testAppleLoginUsesSocialTokenAndRoutesToMain() async {
        let auth = SignInAuthUseCaseSpy()
        let store = makeStore(authUseCase: auth)
        let session = AuthSessionFixture.make()

        await store.send(.appleLoginButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.receiveLoginSessionSuccessfully, session) {
            $0.isLoading = false
            $0.navigationDestination = .routeToMain
        }
        await store.finish()

        XCTAssertEqual(auth.signInRequests.count, 1)
        XCTAssertEqual(auth.signInRequests.first?.loginType, .apple)
        XCTAssertEqual(auth.signInRequests.first?.accessToken, "social-token")
    }

    func testMissingSocialTokenPresentsUnknownErrorWithoutRouting() async {
        let router = SignInRouterSpy()
        let store = makeStore(socialResult: .success(nil), router: router)
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.kakaoLoginButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.kakaoLoginError, .unknown)
        await store.receive(\.showAlert, .error(.unknown)) {
            $0.isLoading = false
            $0.alertCase = .error(.unknown)
        }

        XCTAssertTrue(router.routes.isEmpty)
    }

    func testServerLoginFailurePreservesNetworkError() async {
        let router = SignInRouterSpy()
        let store = makeStore(
            signInResult: .failure(NetworkError.networkUnavailable),
            router: router
        )
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.appleLoginButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.appleLoginError, .networkUnavailable)
        await store.receive(\.showAlert, .error(.networkUnavailable)) {
            $0.isLoading = false
            $0.alertCase = .error(.networkUnavailable)
        }

        XCTAssertTrue(router.routes.isEmpty)
    }

    private func makeStore(
        initialState: SignInFeature.State = SignInFeature.State(),
        isDemoLoginEnabled: Bool = true,
        socialResult: Result<String?, Error> = .success("social-token"),
        signInResult: Result<AuthSession, Error> = .success(AuthSessionFixture.make()),
        authUseCase: AuthUseCaseProtocol? = nil,
        router: SignInRouterSpy? = nil
    ) -> TestStoreOf<SignInFeature> {
        let router = router ?? SignInRouterSpy()
        return TestStore(initialState: initialState) {
            SignInFeature(
                signInUseCase: SignInUseCase(
                    signInRepository: SignInRepositoryStub(isEnabled: isDemoLoginEnabled)
                ),
                socialLoginUseCase: SocialLoginStub(result: socialResult),
                authUseCase: authUseCase ?? AuthUseCaseStub(
                    signInResult: signInResult,
                    userInfoResult: .success(UserInfoFixture.make())
                ),
                router: router.route
            )
        }
    }
}
