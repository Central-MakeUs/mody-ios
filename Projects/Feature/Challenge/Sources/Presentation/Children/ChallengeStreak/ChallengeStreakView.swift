//
//  ChallengeStreakView.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import SwiftUI
import ComposableArchitecture

public struct ChallengeStreakView: View {
    private let store: StoreOf<ChallengeStreakFeature>

    public init(store: StoreOf<ChallengeStreakFeature>) {
        self.store = store
    }

    public var body: some View {
        streakBody
    }
    
    private var streakBody: some View {
        Text("연속 기록")
    }
}
