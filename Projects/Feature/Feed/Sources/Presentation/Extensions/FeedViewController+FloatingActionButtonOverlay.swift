//
//  FeedViewController+FloatingActionButtonOverlay.swift
//  Feed
//
//  Created by 김동준 on 7/12/26.
//

import UIKit
import SnapKit

extension FeedViewController {
    func setFloatingActionButtonOverlayVisible(_ isVisible: Bool) {
        if isVisible {
            showFloatingActionButtonOverlay()
        } else {
            hideFloatingActionButtonOverlay()
        }
    }
    
    func showFloatingActionButtonOverlay() {
        guard let window = view.window else { return }
        guard floatingActionButtonOverlayView.superview == nil else { return }
        
        configureFloatingActionButtonOverlayLayout(in: window)
        floatingActionButton.isHidden = true
        animateFloatingActionButtonOverlayIn()
    }
    
    func hideFloatingActionButtonOverlay() {
        guard floatingActionButtonOverlayView.superview != nil else {
            floatingActionButton.isHidden = false
            return
        }
        
        UIView.animate(withDuration: 0.16, delay: 0, options: [.curveEaseInOut]) {
            self.dimmedControl.alpha = 0
            self.expandedButtonStackView.alpha = 0
            self.expandedButtonStackView.transform = CGAffineTransform(translationX: 0, y: 8)
        } completion: { _ in
            self.floatingActionButtonOverlayView.removeFromSuperview()
            self.dimmedControl.alpha = 1
            self.expandedButtonStackView.alpha = 1
            self.expandedButtonStackView.transform = .identity
            self.floatingActionButton.isHidden = false
        }
    }
}

private extension FeedViewController {
    func configureFloatingActionButtonOverlayLayout(in window: UIView) {
        let floatingButtonFrame = floatingActionButton.convert(
            floatingActionButton.bounds,
            to: window
        )
        
        window.addSubview(floatingActionButtonOverlayView)
        floatingActionButtonOverlayView.addSubview(dimmedControl)
        floatingActionButtonOverlayView.addSubview(expandedButtonStackView)
        floatingActionButtonOverlayView.addSubview(expandedFloatingActionButton)
        
        configureExpandedButtonStackView()
        
        floatingActionButtonOverlayView.snp.remakeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dimmedControl.snp.remakeConstraints {
            $0.edges.equalToSuperview()
        }
        
        expandedButtonStackView.snp.remakeConstraints {
            $0.trailing.equalToSuperview().offset(-(window.bounds.width - floatingButtonFrame.maxX))
            $0.bottom.equalTo(expandedFloatingActionButton.snp.top).offset(-10)
        }
        
        expandedFloatingActionButton.snp.remakeConstraints {
            $0.trailing.equalToSuperview().offset(-(window.bounds.width - floatingButtonFrame.maxX))
            $0.bottom.equalToSuperview().offset(-(window.bounds.height - floatingButtonFrame.maxY))
            $0.size.equalTo(56)
        }
    }
    
    func animateFloatingActionButtonOverlayIn() {
        dimmedControl.alpha = 0
        expandedButtonStackView.alpha = 0
        expandedButtonStackView.transform = CGAffineTransform(translationX: 0, y: 8)
        floatingActionButtonOverlayView.superview?.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut]) {
            self.dimmedControl.alpha = 1
            self.expandedButtonStackView.alpha = 1
            self.expandedButtonStackView.transform = .identity
        }
    }
    
    func configureExpandedButtonStackView() {
        guard expandedButtonStackView.arrangedSubviews.isEmpty else { return }
        
        expandedButtonStackView.addArrangedSubview(
            makeFloatingActionMenuItem(
                label: exerciseRecordLabel,
                button: exerciseRecordButton
            )
        )
        expandedButtonStackView.addArrangedSubview(
            makeFloatingActionMenuItem(
                label: mealRecordLabel,
                button: mealRecordButton
            )
        )
        [exerciseRecordButton, mealRecordButton].forEach {
            $0.snp.makeConstraints {
                $0.size.equalTo(56)
            }
        }
    }
    
    func makeFloatingActionMenuItem(
        label: UILabel,
        button: UIButton
    ) -> UIView {
        let containerView = UIView()
        
        containerView.addSubview(label)
        containerView.addSubview(button)
        
        button.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.size.equalTo(56)
        }
        
        label.snp.makeConstraints {
            $0.centerY.equalTo(button)
            $0.trailing.equalTo(button.snp.leading).offset(-8)
            $0.leading.equalToSuperview()
        }
        
        return containerView
    }
}
