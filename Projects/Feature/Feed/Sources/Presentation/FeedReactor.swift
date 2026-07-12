//
//  FeedReactor.swift
//  Feed
//
//  Created by 김동준 on 7/11/26
//

import ReactorKit
import FeedInterface

public final class FeedReactor: Reactor {
    public let initialState: State = .init()
    private weak var router: FeedRouter?
    
    public struct State {
        var isFloatingActionButtonExpanded = false
    }
    
    public enum Mutation {
        case setFloatingActionButtonExpanded(Bool)
    }
    
    public enum Action {
        case viewDidLoad
        case didTapDimmedOverlay
        case didTapFloatingActionButton
        case didTapRecordButton(FeedRecordType)
    }
    
    public init(router: FeedRouter) {
        self.router = router
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .empty()
        case .didTapDimmedOverlay:
            return .just(.setFloatingActionButtonExpanded(false))
        case .didTapFloatingActionButton:
            return .just(.setFloatingActionButtonExpanded(!currentState.isFloatingActionButtonExpanded))
        case .didTapRecordButton(let recordType):
            return .concat([
                .just(.setFloatingActionButtonExpanded(false)),
                routeToRecord(recordType)
            ])
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setFloatingActionButtonExpanded(let isExpanded):
            newState.isFloatingActionButtonExpanded = isExpanded
        }
        
        return newState
    }
}

private extension FeedReactor {
    func routeToRecord(_ recordType: FeedRecordType) -> Observable<Mutation> {
        return .deferred { [weak router] in
            Task { @MainActor in
                router?.route(from: .routeToRecord(recordType))
            }
            return .empty()
        }
    }
}
