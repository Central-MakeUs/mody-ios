//
//  CameraSelectionOverlayView.swift
//  CoreCamera
//
//  Created by 김동준 on 7/20/26.
//

import DesignSystem
import UIKit

final class CameraSelectionOverlayView: UIView {
    private let horizontalInset: CGFloat = 24
    private let selectionHeight: CGFloat = 200
    
    var selectionFrame: CGRect {
        currentSelectionFrame
    }

    private let dimLayer = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    private var currentSelectionFrame = CGRect.zero
    private var panStartFrame = CGRect.zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if currentSelectionFrame == .zero {
            let width = max(0, bounds.width - (horizontalInset * 2))
            currentSelectionFrame = CGRect(
                x: horizontalInset,
                y: max(0, (bounds.height - selectionHeight) / 2),
                width: width,
                height: min(selectionHeight, bounds.height)
            )
        } else {
            currentSelectionFrame = constrainedFrame(currentSelectionFrame)
        }

        updateLayers()
    }
}

private extension CameraSelectionOverlayView {
    func setupUI() {
        isOpaque = false
        backgroundColor = .clear

        dimLayer.fillColor = UIColor.black.withAlphaComponent(0.35).cgColor
        dimLayer.fillRule = .evenOdd
        layer.addSublayer(dimLayer)

        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.main.cgColor
        borderLayer.lineWidth = 4
        borderLayer.lineDashPattern = [8, 8]
        layer.addSublayer(borderLayer)

        let panGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(didPan(_:))
        )
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }

    func updateLayers() {
        let dimPath = UIBezierPath(rect: bounds)
        dimPath.append(UIBezierPath(rect: currentSelectionFrame))
        dimLayer.frame = bounds
        dimLayer.path = dimPath.cgPath

        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath(rect: currentSelectionFrame).cgPath
    }

    func constrainedFrame(_ frame: CGRect) -> CGRect {
        CGRect(
            x: min(max(0, frame.minX), max(0, bounds.width - frame.width)),
            y: min(max(0, frame.minY), max(0, bounds.height - frame.height)),
            width: min(frame.width, bounds.width),
            height: min(frame.height, bounds.height)
        )
    }

    @objc func didPan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            panStartFrame = currentSelectionFrame
        case .changed:
            let translation = recognizer.translation(in: self)
            currentSelectionFrame = constrainedFrame(
                panStartFrame.offsetBy(dx: translation.x, dy: translation.y)
            )
            updateLayers()
        default:
            break
        }
    }
}

extension CameraSelectionOverlayView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        currentSelectionFrame.contains(touch.location(in: self))
    }
}
