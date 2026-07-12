//
//  FeedReactor.swift
//  Feed
//
//  Created by 김동준 on 7/11/26
//

import ReactorKit

public final class FeedReactor: Reactor {
    public let initialState: State = .init()
    
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
        case didTapExerciseRecordButton
        case didTapMealRecordButton
    }
    
    public init() {}
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .empty()
        case .didTapDimmedOverlay:
            return .just(.setFloatingActionButtonExpanded(false))
        case .didTapFloatingActionButton:
            return .just(.setFloatingActionButtonExpanded(!currentState.isFloatingActionButtonExpanded))
        case .didTapExerciseRecordButton:
            return .just(.setFloatingActionButtonExpanded(false))
        case .didTapMealRecordButton:
            return .just(.setFloatingActionButtonExpanded(false))
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
