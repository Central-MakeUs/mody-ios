import CommonDomain
import ComposableArchitecture
import Foundation
import XCTest
@testable import OnBoarding

@MainActor
final class OnBoardingFeatureTests: XCTestCase {
    func testRequiredAgreementsGateFirstStep() async {
        let store = makeStore()

        await store.send(.nextButtonTapped)
        XCTAssertEqual(store.state.stage, .agreement)

        await store.send(.privacyPolicyAgreementTapped) {
            $0.isPrivacyPolicyAccepted = true
        }
        await store.send(.nextButtonTapped)
        XCTAssertEqual(store.state.stage, .agreement)

        await store.send(.termsOfServiceAgreementTapped) {
            $0.isTermsOfServiceAccepted = true
        }
        await store.send(.nextButtonTapped) {
            $0.stage = .steps
        }
        XCTAssertEqual(store.state.currentStep, .one)
    }

    func testNicknameMustBeValidBeforeAdvancing() async {
        var state = OnBoardingFeature.State()
        state.stage = .steps
        let store = makeStore(initialState: state)

        await store.send(.nextButtonTapped)
        XCTAssertEqual(store.state.currentStep, .one)

        await store.send(.stepOne(.binding(.set(\.nickname, "123456789012345")))) {
            $0.stepOne.nickname = "123456789012345"
        }
        await store.send(.nextButtonTapped)
        XCTAssertEqual(store.state.currentStep, .one)

        await store.send(.stepOne(.binding(.set(\.nickname, "모디")))) {
            $0.stepOne.nickname = "모디"
        }
        await store.send(.nextButtonTapped) {
            $0.request.nickname = "모디"
            $0.currentStep = .two
        }
    }

    func testBirthDateAndWeightsAreStoredWhileAdvancing() async {
        var state = OnBoardingFeature.State()
        state.stage = .steps
        state.currentStep = .two
        let store = makeStore(initialState: state)

        await store.send(.nextButtonTapped) {
            $0.request.birthDate = "2000-01-01"
            $0.currentStep = .three
        }
        await store.send(.nextButtonTapped) {
            $0.request.currentWeightKg = 57
            $0.request.targetWeightKg = 60
            $0.currentStep = .four
        }
    }

    func testProfileSubmissionUsesCollectedValuesAndOpensPermissionStep() async {
        let repository = OnBoardingRepositorySpy()
        let analytics = OnBoardingAnalyticsSpy()
        let store = makeStore(
            initialState: readyToSubmitState(),
            repository: repository,
            analytics: analytics
        )

        await store.send(.nextButtonTapped) {
            $0.request.mealSchedules = $0.stepFour.request.mealSchedules
            $0.request.exerciseSchedules = $0.stepFour.request.exerciseSchedules
        }
        await store.receive(\.setUpProfile) {
            $0.isLoading = true
        }
        await store.receive(\.setupProfileSuccessfully, 42) {
            $0.isLoading = false
            $0.currentStep = .permission
        }
        await store.finish()

        XCTAssertEqual(repository.requests.count, 1)
        XCTAssertEqual(repository.requests.first?.nickname, "모디")
        XCTAssertEqual(repository.requests.first?.birthDate, "2000-01-01")
        XCTAssertEqual(repository.requests.first?.currentWeightKg, 57)
        XCTAssertEqual(repository.requests.first?.targetWeightKg, 60)
        XCTAssertEqual(repository.requests.first?.mealSchedules.count, 3)
        XCTAssertEqual(repository.requests.first?.exerciseSchedules, [
            ExerciseScheduleRequest(dayOfWeek: .monday, time: "09:00")
        ])
        XCTAssertEqual(analytics.userIDs, ["42"])
        XCTAssertEqual(analytics.nicknames, ["모디"])
    }

    func testProfileFailureShowsNetworkErrorAndKeepsCurrentStep() async {
        let repository = OnBoardingRepositorySpy(result: .failure(NetworkError.networkUnavailable))
        let router = OnBoardingRouterSpy()
        let store = makeStore(initialState: readyToSubmitState(), repository: repository, router: router)
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.nextButtonTapped)
        await store.receive(\.setUpProfile) {
            $0.isLoading = true
        }
        await store.receive(\.setupProfileFailure, .networkUnavailable)
        await store.receive(\.showAlert, .error(.networkUnavailable)) {
            $0.isLoading = false
            $0.alertCase = .error(.networkUnavailable)
        }

        XCTAssertEqual(store.state.currentStep, .four)
        XCTAssertTrue(router.routes.isEmpty)
        XCTAssertEqual(repository.requests.count, 1)
    }

    func testUnexpectedProfileFailureShowsUnknownError() async {
        let repository = OnBoardingRepositorySpy(result: .failure(UnexpectedError()))
        let store = makeStore(initialState: readyToSubmitState(), repository: repository)
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.nextButtonTapped)
        await store.receive(\.setUpProfile) {
            $0.isLoading = true
        }
        await store.receive(\.setupProfileFailure, .unknown)
        await store.receive(\.showAlert, .error(.unknown)) {
            $0.isLoading = false
            $0.alertCase = .error(.unknown)
        }
        XCTAssertEqual(store.state.currentStep, .four)
    }

    func testPermissionRequestsFollowSequenceAndRouteEvenWhenDenied() async {
        for shouldRequestHealth in [false, true] {
            let permission = OnBoardingPermissionSpy(shouldRequestHealth: shouldRequestHealth)
            let router = OnBoardingRouterSpy()
            var state = OnBoardingFeature.State()
            state.stage = .steps
            state.currentStep = .permission
            let store = makeStore(initialState: state, permission: permission, router: router)

            await store.send(.nextButtonTapped)
            await store.receive(\.requestPermissions) {
                $0.isPermissionRequesting = true
            }
            await store.receive(\.permissionsRequestCompleted) {
                $0.isPermissionRequesting = false
            }
            await store.receive(\.routeToGroupParticipate)
            await store.finish()

            let expected = shouldRequestHealth
                ? ["notification", "camera", "healthCheck", "health"]
                : ["notification", "camera", "healthCheck"]
            XCTAssertEqual(permission.calls, expected)
            XCTAssertEqual(router.routes, [.routeToGroupParticipate])
        }
    }

    private func readyToSubmitState() -> OnBoardingFeature.State {
        var state = OnBoardingFeature.State()
        state.stage = .steps
        state.currentStep = .four
        state.request.nickname = "모디"
        state.request.birthDate = "2000-01-01"
        state.request.currentWeightKg = 57
        state.request.targetWeightKg = 60
        state.stepFour.selectedWeekdays = [.monday]
        state.stepFour.request.exerciseSchedules = [
            ExerciseScheduleRequest(dayOfWeek: .monday, time: "09:00")
        ]
        return state
    }

    private func makeStore(
        initialState: OnBoardingFeature.State = .init(),
        repository: OnBoardingRepositorySpy = .init(),
        analytics: OnBoardingAnalyticsSpy = .init(),
        permission: OnBoardingPermissionSpy = .init(),
        router: OnBoardingRouterSpy? = nil
    ) -> TestStoreOf<OnBoardingFeature> {
        let router = router ?? OnBoardingRouterSpy()
        return TestStore(initialState: initialState) {
            OnBoardingFeature(
                onBoardingUseCase: OnBoardingUseCase(onBoardingRepository: repository),
                cameraPermission: permission,
                notificationPermission: permission,
                healthPermission: permission,
                analyticsUseCase: analytics,
                router: router.route
            )
        }
    }
}

private struct UnexpectedError: Error {}
