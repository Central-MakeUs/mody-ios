//
//  OnBoardingPathView.swift
//  OnBoarding
//
//  Created by 김동준 on 7/26/26.
//

import ComposableArchitecture
import SwiftUI

struct OnBoardingPathView: View {
    private let store: StoreOf<OnBoardingPath>

    init(store: StoreOf<OnBoardingPath>) {
        self.store = store
    }

    var body: some View {
        switch store.case {
        case .agreementDetail(let store):
            OnBoardingAgreementDetailView(store: store)
        }
    }
}
