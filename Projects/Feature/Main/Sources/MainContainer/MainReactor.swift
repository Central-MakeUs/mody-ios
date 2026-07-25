//
//  MainReactor.swift
//  Main
//
//  Created by 김동준 on 7/24/26.
//

import CoreNotificationInterface
import ReactorKit
import RxSwift

public final class MainReactor: Reactor {
    public enum Action {
        case viewWillAppear
    }

    public enum Mutation {
        case setUnreadNotification(Bool)
    }

    public struct State {
        var hasUnreadNotification = false
    }

    public let initialState = State()

    private let notificationUseCase: NotificationUseCaseProtocol

    public init(notificationUseCase: NotificationUseCaseProtocol) {
        self.notificationUseCase = notificationUseCase
    }

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return fetchUnreadNotification()
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setUnreadNotification(hasUnreadNotification):
            newState.hasUnreadNotification = hasUnreadNotification
        }

        return newState
    }
}

private extension MainReactor {
    func fetchUnreadNotification() -> Observable<Mutation> {
        Observable.create { [notificationUseCase] observer in
            let task = Task {
                do {
                    let hasUnreadNotification = try await notificationUseCase.hasUnreadNotification()

                    observer.onNext(.setUnreadNotification(hasUnreadNotification))
                    observer.onCompleted()
                } catch {
                    observer.onCompleted()
                }
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
