//
//  NavigationBarDemo.swift
//  DesignSystemDemo
//
//  Created by 김동준 on 7/6/26.
//

import SwiftUI
import UIKit
import DesignSystem

struct NavigationBarDemo: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                MainNavigationBarRepresentable()

                MNavigationBar()

                MNavigationBar(hasExitButton: true)

                MNavigationBar(title: "Label")

                MNavigationBar(title: "MODY", image: .imgModyAppIcon)
            }
        }
        .navigationTitle("NavigationBar")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

private struct MainNavigationBarRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> MainNavigationBar {
        MainNavigationBar()
    }

    func updateUIView(_ uiView: MainNavigationBar, context: Context) { }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: MainNavigationBar,
        context: Context
    ) -> CGSize? {
        uiView.systemLayoutSizeFitting(
            CGSize(
                width: proposal.width ?? UIView.layoutFittingCompressedSize.width,
                height: UIView.layoutFittingCompressedSize.height
            ),
            withHorizontalFittingPriority: proposal.width == nil ? .fittingSizeLevel : .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}
