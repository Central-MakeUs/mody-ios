//  AlertViewModifier.swift
//  Base
//
//  Created by 김동준 on 7/19/26.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

struct AlertViewModifier<AlertContent: View>: ViewModifier {
    private let store: StoreOf<AlertFeature>
    private let alertContent: () -> AlertContent

    init(
        store: StoreOf<AlertFeature>,
        @ViewBuilder alertContent: @escaping () -> AlertContent
    ) {
        self.store = store
        self.alertContent = alertContent
    }

    func body(content: Content) -> some View {
        ZStack {
            content
                .allowsHitTesting(store.contentAllowsHitTesting)

            Color.systemBlack
                .opacity(store.scrimOpacity)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .allowsHitTesting(store.isPresented)
                .onTapGesture {
                    store.send(.scrimTapped)
                }

            if store.isPresented {
                alertContent()
            }
        }
    }
}
