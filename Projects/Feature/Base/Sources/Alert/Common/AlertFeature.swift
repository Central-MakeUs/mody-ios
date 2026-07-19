//  AlertFeature.swift
//  Base
//
//  Created by 김동준 on 7/19/26.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct AlertFeature: Reducer {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var scrimOpacity: CGFloat
        var contentAllowsHitTesting: Bool
        public internal(set) var isPresented: Bool
        public var dismissOnScrimTap: Bool

        public init(dismissOnScrimTap: Bool = true) {
            scrimOpacity = .zero
            contentAllowsHitTesting = true
            isPresented = false
            self.dismissOnScrimTap = dismissOnScrimTap
        }
    }

    public enum Action {
        case present
        case dismiss
        case scrimTapped
        case scrimOpacityChanged(opacity: CGFloat)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .present:
                state.isPresented = true
                state.contentAllowsHitTesting = false
                return .send(.scrimOpacityChanged(opacity: 0.6))

            case .dismiss:
                state.isPresented = false
                state.contentAllowsHitTesting = true
                return .send(.scrimOpacityChanged(opacity: .zero))

            case .scrimTapped:
                guard state.dismissOnScrimTap else { return .none }
                return .send(.dismiss)

            case let .scrimOpacityChanged(opacity):
                state.scrimOpacity = opacity
                return .none
            }
        }
    }
}
