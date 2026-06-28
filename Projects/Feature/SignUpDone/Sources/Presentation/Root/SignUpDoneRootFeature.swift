//
//  SignUpDoneRootFeature.swift
//  SignUpDone
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture
import SignUpDoneInterface

@Reducer
public struct SignUpDoneRootFeature {
    private let router: @MainActor (SignUpDoneRoute) -> Void
    
    public init(router: @escaping @MainActor (SignUpDoneRoute) -> Void) {
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var path: StackState<SignUpDonePath.State> = .init()
        var signUpDoneState: SignUpDoneFeature.State = .init()
    }
    
    public enum Action: BindableAction {
        case path(StackActionOf<SignUpDonePath>)
        case binding(BindingAction<State>)
        case signUpDoneAction(SignUpDoneFeature.Action)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
                
        Reduce { state, action in
            switch action {
            case .path(.element(id: _, action: let action)):
                return .none
            case .signUpDoneAction:
                return .none
            case .path:
                return .none
            case .binding:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
