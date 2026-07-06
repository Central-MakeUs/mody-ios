//
//  GroupInviteView.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import SwiftUI
import ComposableArchitecture

public struct GroupInviteView: View {
    private let store: StoreOf<GroupInviteFeature>
    
    public init(store: StoreOf<GroupInviteFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Text("Hello, GroupInviteView")
    }
}
