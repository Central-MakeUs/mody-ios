//
//  ChallengeDetailView.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import SwiftUI
import ComposableArchitecture

public struct ChallengeDetailView: View {
    private let store: StoreOf<ChallengeDetailFeature>

    public init(store: StoreOf<ChallengeDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        detailBody
    }
    
    private var detailBody: some View {
        Text("챌린지")
    }
}
