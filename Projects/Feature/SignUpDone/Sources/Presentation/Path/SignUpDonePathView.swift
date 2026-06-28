//
//  SignUpDonePathView.swift
//  SignUpDone
//
//  Created by 김동준 on 6/26/26
//

import SwiftUI
import ComposableArchitecture

public struct SignUpDonePathView: View {
    private let store: StoreOf<SignUpDonePath>
    
    public init(store: StoreOf<SignUpDonePath>) {
        self.store = store
    }
    
    public var body: some View {
        switch store.case {
        case .temp(let store): TempView(store: store)
        }
    }
}
