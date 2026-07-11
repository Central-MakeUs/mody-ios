//
//  CircleImageButton.swift
//  Feed
//
//  Created by 김동준 on 7/11/26
//

import UIKit
import SnapKit

final class CircleImageButton: UIButton {
    private let buttonSize: CGFloat = 56
    private let iconSize: CGFloat = 24
    private let iconImageView = UIImageView()

    init(
        backgroundColor: UIColor,
        icon: UIImage,
        iconTintColor: UIColor
    ) {
        super.init(frame: .zero)
        setupUI(
            backgroundColor: backgroundColor,
            icon: icon,
            iconTintColor: iconTintColor
        )
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CircleImageButton {
    func setupUI(
        backgroundColor: UIColor,
        icon: UIImage,
        iconTintColor: UIColor
    ) {
        self.backgroundColor = backgroundColor
        layer.cornerRadius = buttonSize / 2
        layer.masksToBounds = true

        iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = iconTintColor
        iconImageView.contentMode = .scaleAspectFit
    }

    func setupLayout() {
        addSubview(iconImageView)

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(iconSize)
        }
    }
}
