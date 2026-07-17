//
//  UIViewController+Hosting.swift
//  Base
//
//  Created by 김동준 on 7/16/26.
//

import UIKit
import SwiftUI

public extension UIViewController {
    @discardableResult
    func addHostedView<Content: SwiftUI.View>(
        _ rootView: Content,
        to containerView: UIView,
        sizesToContent: Bool = false
    ) -> UIHostingController<Content> {
        let hostingController = UIHostingController(rootView: rootView)

        if sizesToContent {
            hostingController.sizingOptions = .intrinsicContentSize
        }

        addChild(hostingController)

        let hostedView = hostingController.view!
        hostedView.backgroundColor = .clear
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(hostedView)

        NSLayoutConstraint.activate([
            hostedView.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostedView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            hostedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)

        return hostingController
    }
}
