//
//  GroupParticipateView.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import SwiftUI
import ComposableArchitecture

public struct GroupParticipateView: View {
    private let store: StoreOf<GroupParticipateFeature>
    
    public init(store: StoreOf<GroupParticipateFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Text("Hello, GroupParticipateView")
    }
}
