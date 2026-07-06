//
//  ModyGroupPathView.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import SwiftUI
import ComposableArchitecture

public struct ModyGroupPathView: View {
    private let store: StoreOf<ModyGroupPath>
    
    public init(store: StoreOf<ModyGroupPath>) {
        self.store = store
    }
    
    public var body: some View {
        switch store.case {
        case .temp(let store): TempView(store: store)
        }
    }
}
