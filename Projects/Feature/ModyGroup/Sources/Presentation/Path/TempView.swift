//
//  TempView.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import SwiftUI
import ComposableArchitecture

public struct TempView: View {
    var store: StoreOf<TempFeature>
    
    public var body: some View {
        Text("Hello, World!")
    }
}

@Reducer
public struct TempFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {
    }
    
    public init() {}
    public var body: some ReducerOf<Self> {
                
        Reduce { state, action in
            return .none
        }
    }
}
