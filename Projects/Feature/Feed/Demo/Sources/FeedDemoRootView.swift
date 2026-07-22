//
//  FeedDemoRootView.swift
//  FeedDemo
//
//  Created by 김동준 on 7/22/26.
//

import SwiftUI
import UIKit

struct FeedDemoRootView: UIViewControllerRepresentable {
    let coordinator: FeedDemoCoordinator

    func makeUIViewController(context: Context) -> UINavigationController {
        coordinator.makeRootViewController()
    }

    func updateUIViewController(
        _ uiViewController: UINavigationController,
        context: Context
    ) {}
}
