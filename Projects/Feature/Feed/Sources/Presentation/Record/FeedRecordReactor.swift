//
//  FeedRecordReactor.swift
//  Feed
//
//  Created by 김동준 on 7/12/26.
//

import ReactorKit
import FeedInterface

public final class FeedRecordReactor: Reactor {
    public let initialState: State
    private weak var router: FeedRecordRouter?

    public struct State {
        let recordType: FeedRecordType
    }

    public enum Action {
        case didTapBackButton
    }

    public enum Mutation {}

    public init(
        router: FeedRecordRouter,
        recordType: FeedRecordType
    ) {
        self.router = router
        self.initialState = State(recordType: recordType)
    }

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapBackButton:
            return routeToBack()
        }
    }
}

private extension FeedRecordReactor {
    func routeToBack() -> Observable<Mutation> {
        return .deferred { [weak router] in
            Task { @MainActor in
                router?.route(from: .back)
            }
            return .empty()
        }
    }
}
