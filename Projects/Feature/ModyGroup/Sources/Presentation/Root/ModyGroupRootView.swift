//
//  ModyGroupRootView.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture
import SwiftUI

public struct ModyGroupRootView: View {
    @Bindable private var store: StoreOf<ModyGroupRootFeature>
    
    public init(store: StoreOf<ModyGroupRootFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            switch store.initialScreen {
            case .participate:
                GroupParticipateView(
                    store: store.scope(
                        state: \.groupParticipateState,
                        action: \.groupParticipateAction
                    )
                )
            case .create:
                GroupCreateView(
                    store: store.scope(
                        state: \.groupCreateState,
                        action: \.groupCreateAction
                    )
                )
            }
        } destination: { store in
            ModyGroupPathView(store: store)
        }
    }
}
