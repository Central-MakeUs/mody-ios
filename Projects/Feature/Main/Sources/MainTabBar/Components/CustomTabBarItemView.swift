//
//  CustomTabBarItemView.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import SnapKit
import DesignSystem

final class CustomTabBarItemView: UIControl {
    var onTap: (() -> Void)?

    private let iconImageView = UIImageView()
    private let titleLabel = MUILabel(style: .c3)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTap() {
        onTap?()
    }
}

extension CustomTabBarItemView {
    func configure(tab: MainTab, isSelected: Bool) {
        let color = isSelected ? UIColor.gray10 : UIColor.gray5
        let image = tab.image

        iconImageView.image = image?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = color

        titleLabel.configure(
            text: tab.title,
            style: .c3,
            color: color
        )
    }
}

private extension CustomTabBarItemView {
    func setupUI() {
        iconImageView.backgroundColor = .clear
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.textAlignment = .center
    }
    
    func setupLayout() {
        addSubview(iconImageView)
        addSubview(titleLabel)

        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(MainTabBarConstants.itemTopInset)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(MainTabBarConstants.itemIconSize)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(MainTabBarConstants.itemIconTitleSpacing)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(MainTabBarConstants.itemHorizontalInset)
            $0.trailing.lessThanOrEqualToSuperview().offset(-MainTabBarConstants.itemHorizontalInset)
        }
    }
}
