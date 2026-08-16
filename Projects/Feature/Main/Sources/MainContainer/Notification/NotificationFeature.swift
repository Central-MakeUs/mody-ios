//
//  NotificationFeature.swift
//  Main
//
//  Created by 김동준 on 7/24/26.
//

import Base
import CommonDomain
import ComposableArchitecture
import CoreNotificationInterface
import FeedInterface
import Foundation

@Reducer
struct NotificationFeature {
    private let notificationUseCase: NotificationUseCaseProtocol
    private let router: @MainActor (NotificationRoute) -> Void

    init(
        notificationUseCase: NotificationUseCaseProtocol,
        router: @escaping @MainActor (NotificationRoute) -> Void
    ) {
        self.notificationUseCase = notificationUseCase
        self.router = router
    }

    @ObservableState
    struct State: Equatable {
        enum AlertCase: Equatable {
            case error(NetworkError)
        }

        var alertCase: AlertCase?
        var alertState = AlertFeature.State()
        var notifications: [NotificationItem] = []
        var nextCursor: Int?
        var hasNext = false
        var isLoading = false
        var isLoadingNextPage = false
        var didLoad = false
        let isPhaseOne: Bool = PhaseManager.shared.isPhaseOne

        var isNotificationEmpty: Bool {
            didLoad && !isLoading && notifications.isEmpty
        }

        init() {}
    }

    enum Action {
        case alertAction(AlertFeature.Action)
        case onAppear
        case backButtonTapped
        case notificationTapped(NotificationItem)
        case loadNextPage
        case notificationsFetched(NotificationPage)
        case showAlert(State.AlertCase)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.alertState, action: \.alertAction) {
            AlertFeature()
        }

        Reduce { state, action in
            switch action {
            case .alertAction(.dismiss):
                state.alertCase = nil
                return .none
            case .alertAction:
                return .none
            case .backButtonTapped:
                return .run { [router] _ in
                    await router(.back)
                }
            case let .notificationTapped(item):
                return route(for: item.type)
            case .onAppear:
                guard !state.didLoad else { return .none }
                state.didLoad = true
                state.isLoading = true

                return .run { send in
                    await send(fetchNotifications(cursor: nil))
                }
            case let .notificationsFetched(page):
                state.isLoading = false
                state.isLoadingNextPage = false
                state.nextCursor = page.nextCursor
                state.hasNext = page.hasNext

                let notifications = state.isPhaseOne
                    ? page.notifications.filter {
                        $0.type == .exerciseReminder || $0.type == .mealReminder
                    }
                    : page.notifications

                if state.notifications.isEmpty {
                    state.notifications = notifications
                } else {
                    state.notifications.append(contentsOf: notifications)
                }

                return .none
            case .loadNextPage:
                guard
                    state.hasNext,
                    !state.isLoading,
                    !state.isLoadingNextPage
                else {
                    return .none
                }

                state.isLoadingNextPage = true
                let nextCursor = state.nextCursor

                return .run { send in
                    await send(fetchNotifications(cursor: nextCursor))
                }
            case let .showAlert(alertCase):
                state.isLoading = false
                state.isLoadingNextPage = false
                state.alertCase = alertCase
                return .send(.alertAction(.present))
            }
        }
    }
}

private extension NotificationFeature {
    func route(for notificationType: NotificationType) -> Effect<Action> {
        switch notificationType {
        case .groupMemberJoined, .groupRecordStreakRisk, .buddyNudge:
            return .run { [router] _ in
                await router(.feed)
            }
        case .exerciseReminder:
            return .run { [router] _ in
                await router(.record(.exercise))
            }
        case .mealReminder:
            return .run { [router] _ in
                await router(.record(.meal))
            }
        case .stepChallengeCompleted, .weeklyChallengeCompleted:
            return .run { [router] _ in
                await router(.challenge)
            }
        case .commentCreated:
            return .none
        }
    }

    func fetchNotifications(cursor: Int?) async -> Action {
        do {
            let page = try await notificationUseCase.getNotifications(
                cursor: cursor,
                size: 15,
                allRead: true
            )
            return .notificationsFetched(page)
        } catch {
            return .showAlert(.error(error as? NetworkError ?? .unknown))
        }
    }
}

// TODO: MicroFeature로 구조 바꾸면서 빠질 예정
enum NotificationRoute: Equatable {
    case back
    case feed
    case challenge
    case record(FeedRecordType)
}
