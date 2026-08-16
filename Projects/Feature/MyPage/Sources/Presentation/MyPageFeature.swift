//
//  MyPageFeature.swift
//  MyPage
//
//  Created by 김동준 on 7/12/26.
//

import ComposableArchitecture
import CommonDomain
import CoreAuthInterface
import Foundation
import MyPageInterface

@Reducer
public struct MyPageFeature {
    private let authUseCase: AuthUseCaseProtocol
    private let myPageUseCase: MyPageUseCase
    private let router: @MainActor (MyPageRoute) -> Void
    private let output: @MainActor (MyPageOutput) -> Void

    public init(
        authUseCase: AuthUseCaseProtocol,
        myPageUseCase: MyPageUseCase,
        router: @escaping @MainActor (MyPageRoute) -> Void,
        output: @escaping @MainActor (MyPageOutput) -> Void
    ) {
        self.authUseCase = authUseCase
        self.myPageUseCase = myPageUseCase
        self.router = router
        self.output = output
    }

    @ObservableState
    public struct State: Equatable {
        var userInfo: UserInfo? = nil
        var weightRecord: WeightRecord? = nil
        var defaultAvatar: DefaultAvatar
        var isLoading = false
        var isProfileRefreshing = false
        var isAllFetched = false
        let isPhaseOne = PhaseManager.shared.isPhaseOne
        @Presents var weightRecordSheet: WeightRecordFeature.State?

        public init(defaultAvatar: DefaultAvatar = .random()) {
            self.defaultAvatar = defaultAvatar
        }

        var profileImageURL: URL? {
            guard let profileImageUrl = userInfo?.profileImageUrl else {
                return nil
            }

            return URL(string: profileImageUrl)
        }
    }

    public enum Action {
        case input(MyPageInput)
        case onAppear
        case userInfoFetched(UserInfo)
        case userInfoFetchFailed
        case weightRecordFetched(WeightRecord)
        case weightRecordFetchFailed
        case profileEditButtonTapped
        case weightRecordButtonTapped
        case weightRecordSheet(PresentationAction<WeightRecordFeature.Action>)
        case weightRecordSucceeded(Double)
        case weightRecordFailed(NetworkError)
        case notificationSettingsButtonTapped
        case groupSettingsButtonTapped
        case healthDataSettingsButtonTapped
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .input(.profileUpdated):
                state.isProfileRefreshing = true
                return .run { send in
                    await send(getUserInfo())
                }
            case .onAppear:
                guard !state.isAllFetched else { return .none }
                state.isAllFetched = true

                return .merge(
                    .run { send in
                        await send(getUserInfo())
                    },
                    .run { send in
                        await send(getWeightRecord())
                    }
                )
            case let .userInfoFetched(userInfo):
                state.userInfo = userInfo
                state.isProfileRefreshing = false
                return .none
            case .userInfoFetchFailed:
                state.isProfileRefreshing = false
                return .none
            case let .weightRecordFetched(weightRecord):
                state.weightRecord = weightRecord
                return .none
            case .weightRecordFetchFailed:
                return .none
            case .profileEditButtonTapped:
                guard state.userInfo != nil else {
                    return .none
                }

                let profileImageURL = state.profileImageURL
                let defaultAvatar = state.defaultAvatar

                return .run { [router] _ in
                    await router(
                        .routeToProfile(
                            profileImageURL: profileImageURL,
                            defaultAvatar: defaultAvatar
                        )
                    )
                }
            case .weightRecordButtonTapped:
                guard let weightRecord = state.weightRecord else { return .none }

                state.weightRecordSheet = WeightRecordFeature.State(
                    currentWeight: weightRecord.currentWeightKg
                )
                return .none
            case .weightRecordSheet(.presented(.recordButtonTapped)):
                guard !state.isLoading else { return .none }

                guard
                    let weightRecordSheet = state.weightRecordSheet,
                    let recordedOn = weightRecordSheet.recordedOn
                else {
                    state.weightRecordSheet = nil
                    return .none
                }

                let weightKg = weightRecordSheet.currentWeight
                state.isLoading = true
                state.weightRecordSheet = nil

                return .run { [output] send in
                    await output(.weightRecordStarted)

                    do {
                        try await myPageUseCase.recordWeight(
                            recordedOn: recordedOn,
                            weightKg: weightKg
                        )
                        await send(.weightRecordSucceeded(weightKg))
                    } catch let error as NetworkError {
                        await send(.weightRecordFailed(error))
                    } catch {
                        await send(.weightRecordFailed(.unknown))
                    }
                }
            case let .weightRecordSucceeded(weightKg):
                state.isLoading = false

                if let weightRecord = state.weightRecord {
                    state.weightRecord = WeightRecord(
                        startWeightKg: weightRecord.startWeightKg,
                        currentWeightKg: weightKg,
                        targetWeightKg: weightRecord.targetWeightKg
                    )
                }

                return .run { [output] _ in
                    await output(.weightRecordSucceeded)
                }
            case let .weightRecordFailed(error):
                state.isLoading = false

                return .run { [output] _ in
                    await output(.weightRecordFailed(error))
                }
            case .weightRecordSheet:
                return .none
            case .notificationSettingsButtonTapped:
                return .run { [router] _ in
                    await router(.routeToNotificationSettings)
                }
            case .groupSettingsButtonTapped:
                return .run { [router] _ in
                    await router(.routeToGroupSettings)
                }
            case .healthDataSettingsButtonTapped:
                return .run { [router] _ in
                    await router(.routeToHealthDataSettings)
                }
            }
        }
        .ifLet(\.$weightRecordSheet, action: \.weightRecordSheet) {
            WeightRecordFeature()
        }
    }
}

private extension MyPageFeature {
    func getUserInfo() async -> Action {
        do {
            let userInfo = try await authUseCase.getUserInfo(needUpdateKeyChain: false)
            return .userInfoFetched(userInfo)
        } catch {
            return .userInfoFetchFailed
        }
    }

    func getWeightRecord() async -> Action {
        do {
            let weightRecord = try await myPageUseCase.getWeightRecord()
            return .weightRecordFetched(weightRecord)
        } catch {
            return .weightRecordFetchFailed
        }
    }
}
