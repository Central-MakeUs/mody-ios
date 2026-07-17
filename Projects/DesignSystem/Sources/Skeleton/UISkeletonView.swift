//
//  UISkeletonView.swift
//  DesignSystem
//
//  Created by 김동준 on 7/13/26.
//

import UIKit

public final class UISkeletonView: UIView {
    private let width: CGFloat
    private let height: CGFloat
    private let cornerRadius: CGFloat = 4
    private let gradientLayer = CAGradientLayer()

    public override var intrinsicContentSize: CGSize {
        CGSize(width: width, height: height)
    }

    public init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        super.init(frame: .zero)
        setupUI()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    public func startAnimating() {
        guard gradientLayer.animation(forKey: "skeleton") == nil else { return }

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1, -0.5, 0]
        animation.toValue = [1, 1.5, 2]
        animation.duration = 1.2
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "skeleton")
    }

    public func stopAnimating() {
        gradientLayer.removeAnimation(forKey: "skeleton")
    }
}

private extension UISkeletonView {
    func setupUI() {
        backgroundColor = .gray2
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true

        gradientLayer.colors = [
            UIColor.gray2.cgColor,
            UIColor.gray1.cgColor,
            UIColor.gray2.cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
    }
}
