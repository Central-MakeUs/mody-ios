//  View+Alert.swift
//  Base
//
//  Created by 김동준 on 7/19/26.
//

import ComposableArchitecture
import SwiftUI

public extension View {
    @ViewBuilder
    func mAlert(
        _ store: StoreOf<AlertFeature>,
        content: @escaping () -> some View
    ) -> some View {
        modifier(
            AlertViewModifier(
                store: store,
                alertContent: content
            )
        )
    }
}
