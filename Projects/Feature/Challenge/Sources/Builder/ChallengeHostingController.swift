//
//  ChallengeHostingController.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import ChallengeInterface
import ComposableArchitecture
import SwiftUI

final class ChallengeHostingController: UIHostingController<ChallengeView>, ChallengeInputHandler {
    private let store: StoreOf<ChallengeFeature>

    init(store: StoreOf<ChallengeFeature>) {
        self.store = store
        super.init(rootView: ChallengeView(store: store))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func handle(input: ChallengeInput) {
        store.send(.input(input))
    }
}
