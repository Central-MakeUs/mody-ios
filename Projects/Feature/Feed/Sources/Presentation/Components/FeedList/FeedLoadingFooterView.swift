//
//  FeedLoadingFooterView.swift
//  Feed
//
//  Created by 김동준 on 7/21/26
//

import UIKit
import SwiftUI
import DesignSystem
import SnapKit

final class FeedLoadingFooterView: UICollectionReusableView {
    static let reuseIdentifier = "FeedLoadingFooterView"

    private var hostingController: UIHostingController<AnyView>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FeedLoadingFooterView {
    func setupLayout() {
        let loadingView = MLoadingIndicatorView()
            .frame(width: 36, height: 36)
        let hostingController = UIHostingController(rootView: AnyView(loadingView))

        hostingController.view.backgroundColor = .clear
        self.hostingController = hostingController

        addSubview(hostingController.view)
        hostingController.view.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
