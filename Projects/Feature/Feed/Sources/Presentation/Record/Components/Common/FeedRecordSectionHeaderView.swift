//
//  FeedRecordSectionHeaderView.swift
//  Feed
//
//  Created by 김동준 on 7/16/26.
//

import UIKit
import DesignSystem
import SnapKit

final class FeedRecordSectionHeaderView: UIView {
    private let stackView = UIStackView()
    private let iconImageView = UIImageView()
    private let titleLabel = MUILabel(
        style: .b7,
        color: .gray8,
        alignment: .left
    )

    init(icon: UIImage, title: String, spacing: CGFloat = 8) {
        super.init(frame: .zero)
        iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
        setupUI(spacing: spacing, title: title)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FeedRecordSectionHeaderView {
    func setupUI(spacing: CGFloat, title: String) {
        titleLabel.text = title

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = spacing

        iconImageView.tintColor = .gray8
        iconImageView.contentMode = .scaleAspectFit
    }

    func setupLayout() {
        addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }
    }
}
