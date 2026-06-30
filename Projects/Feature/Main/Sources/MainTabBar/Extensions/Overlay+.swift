//
//  Overlay+.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import SnapKit

extension MainTabBarController {
    func showOverlay(_ overlayView: UIView) {
        currentOverlayView?.removeFromSuperview()

        view.addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        currentOverlayView = overlayView
    }
}
