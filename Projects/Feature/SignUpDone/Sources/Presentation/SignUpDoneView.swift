//
//  SignUpDoneView.swift
//  SignUpDone
//
//  Created by 김동준 on 6/26/26
//

import SwiftUI
import ComposableArchitecture

public struct SignUpDoneView: View {
    private let store: StoreOf<SignUpDoneFeature>
    
    public init(store: StoreOf<SignUpDoneFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Text("Hello, SignUpDoneView")
    }
}
