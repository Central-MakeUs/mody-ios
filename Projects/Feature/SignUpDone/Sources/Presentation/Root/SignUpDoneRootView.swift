//
//  SignUpDoneRootView.swift
//  SignUpDone
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture
import SwiftUI

public struct SignUpDoneRootView: View {
    @Bindable private var store: StoreOf<SignUpDoneRootFeature>
    
    public init(store: StoreOf<SignUpDoneRootFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            SignUpDoneView(store: store.scope(state: \.signUpDoneState, action: \.signUpDoneAction))
        } destination: { store in
            SignUpDonePathView(store: store)
        }
    }
}
