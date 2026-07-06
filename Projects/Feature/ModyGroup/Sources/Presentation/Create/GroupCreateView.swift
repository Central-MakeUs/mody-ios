//
//  GroupCreateView.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import SwiftUI
import ComposableArchitecture

public struct GroupCreateView: View {
    private let store: StoreOf<GroupCreateFeature>
    
    public init(store: StoreOf<GroupCreateFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Text("Hello, GroupCreateView")
    }
}
