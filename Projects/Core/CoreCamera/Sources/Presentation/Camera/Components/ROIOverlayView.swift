//
//  ROIOverlayView.swift
//  CoreCamera
//
//  Created by 김동준 on 7/20/26.
//

import DesignSystem
import UIKit

final class ROIOverlayView: UIView {
    private let horizontalInset: CGFloat = 24
    private let selectionHeight: CGFloat = 200
    private let selectionSize: CGSize?
    
    var selectionFrame: CGRect {
        currentSelectionFrame
    }

    private let dimLayer = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    private var selectableFrame: CGRect?
    private var currentSelectionFrame = CGRect.zero
    private var panStartFrame = CGRect.zero

    func resetSelection(in selectableFrame: CGRect?) {
        self.selectableFrame = selectableFrame
        currentSelectionFrame = defaultSelectionFrame()
        updateLayers()
    }

    init(selectionSize: CGSize?) {
        self.selectionSize = selectionSize
        super.init(frame: .zero)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if currentSelectionFrame == .zero {
            currentSelectionFrame = defaultSelectionFrame()
        } else {
            currentSelectionFrame = constrainedFrame(currentSelectionFrame)
        }

        updateLayers()
    }
}

private extension ROIOverlayView {
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

    func defaultSelectionFrame() -> CGRect {
        let selectableFrame = effectiveSelectableFrame()
        if let selectionSize {
            let width = min(selectionSize.width, selectableFrame.width)
            let height = min(selectionSize.height, selectableFrame.height)

            return CGRect(
                x: selectableFrame.midX - (width / 2),
                y: selectableFrame.midY - (height / 2),
                width: width,
                height: height
            )
        }

        let horizontalMargin = min(horizontalInset, selectableFrame.width / 2)
        let width = max(0, selectableFrame.width - (horizontalMargin * 2))
        let height = min(selectionHeight, selectableFrame.height)

        return CGRect(
            x: selectableFrame.minX + horizontalMargin,
            y: selectableFrame.minY + max(0, (selectableFrame.height - height) / 2),
            width: width,
            height: height
        )
    }

    func effectiveSelectableFrame() -> CGRect {
        guard let selectableFrame else { return bounds }

        let effectiveFrame = selectableFrame.intersection(bounds)
        guard !effectiveFrame.isNull,
              effectiveFrame.width > 0,
              effectiveFrame.height > 0 else { return bounds }

        return effectiveFrame
    }

    func constrainedFrame(_ frame: CGRect) -> CGRect {
        let selectableFrame = effectiveSelectableFrame()
        let width = min(frame.width, selectableFrame.width)
        let height = min(frame.height, selectableFrame.height)

        return CGRect(
            x: min(
                max(selectableFrame.minX, frame.minX),
                max(selectableFrame.minX, selectableFrame.maxX - width)
            ),
            y: min(
                max(selectableFrame.minY, frame.minY),
                max(selectableFrame.minY, selectableFrame.maxY - height)
            ),
            width: width,
            height: height
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

extension ROIOverlayView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        currentSelectionFrame.contains(touch.location(in: self))
    }
}
