//
//  CustomTabBarItemView.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import SnapKit

final class CustomTabBarItemView: UIControl {
    var onTap: (() -> Void)?

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(tab: MainTab, isSelected: Bool) {
        let color = isSelected ? UIColor.red : UIColor.black
        let image = isSelected ? tab.selectedImage : tab.normalImage

        iconImageView.image = image?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = color

        titleLabel.text = tab.title
        titleLabel.textColor = color
    }

    private func configureLayout() {
        iconImageView.backgroundColor = .clear
        iconImageView.contentMode = .scaleAspectFit

//        titleLabel.font =
        titleLabel.textAlignment = .center

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

    @objc private func didTap() {
        onTap?()
    }
}
