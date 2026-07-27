//
//  FeedRecordViewController+Alert.swift
//  Feed
//
//  Created by 김동준 on 7/25/26.
//

import Foundation
import DesignSystem
import SwiftUI
import CommonDomain

extension FeedRecordViewController {
    func configureRecordLoadingView() {
        let loadingView = MLoadingIndicatorView()
            .greedyFrame()
            .background(Color.systemBlack.opacity(0.6))
        let hostingController = UIHostingController(rootView: AnyView(loadingView))
        
        hostingController.view.backgroundColor = .clear
        hostingController.view.isHidden = true
        recordLoadingHostingController = hostingController
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        hostingController.didMove(toParent: self)
    }
    
    func setRecordLoadingVisible(_ isVisible: Bool) {
        recordLoadingHostingController?.view.isHidden = !isVisible
        
        if isVisible,
           let loadingView = recordLoadingHostingController?.view {
            view.bringSubviewToFront(loadingView)
        }
    }
    
    func setRecordFailureAlert(_ error: NetworkError?) {
        guard let error else {
            dismissRecordFailureAlert()
            return
        }

        guard recordFailureAlertHostingController == nil else { return }

        let title: String
        let contents: String
        if case let .serverError(_, _, fallback) = error {
            title = fallback.title
            contents = fallback.message
        } else {
            title = error.title
            contents = error.message
        }

        let alertView = MAlertView(
            title: title,
            contents: contents,
            trailingButton: MAlertButton("확인") { [weak self] in
                self?.reactor?.action.onNext(.didDismissRecordFailureAlert)
            },
            onDismiss: { [weak self] in
                self?.reactor?.action.onNext(.didDismissRecordFailureAlert)
            }
        )
        recordFailureAlertHostingController = addHostedView(alertView, to: view)
    }

    func dismissRecordFailureAlert() {
        guard let recordFailureAlertHostingController else { return }

        recordFailureAlertHostingController.willMove(toParent: nil)
        recordFailureAlertHostingController.view.removeFromSuperview()
        recordFailureAlertHostingController.removeFromParent()
        self.recordFailureAlertHostingController = nil
    }
}
