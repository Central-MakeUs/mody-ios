//
//  FeedReactor.swift
//  Feed
//
//  Created by 김동준 on 7/11/26
//

import ReactorKit

public final class FeedReactor: Reactor {
    public let initialState: State = .init()
    
    public struct State {}
    
    public enum Mutation {}
    
    public enum Action {
        case viewDidLoad
        case floatingActionButtonTapped
    }
    
    public init() {}
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .empty()
        case .floatingActionButtonTapped:
            print("Feed floating action button tapped")
            return .empty()
        }
    }
}
