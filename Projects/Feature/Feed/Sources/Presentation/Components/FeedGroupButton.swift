//
//  FeedGroupButton.swift
//  Feed
//
//  Created by 김동준 on 7/13/26.
//

import UIKit
import DesignSystem
import SnapKit

final class FeedGroupButton: UIButton {
    private let horizontalPadding: CGFloat = 24
    private let verticalPadding: CGFloat = 8
    private let iconSize: CGFloat = 24
    private let contentSpacing: CGFloat = 4

    private let contentStackView = UIStackView()
    private let groupTitleLabel = MUILabel(
        style: .b2,
        color: .gray10,
        alignment: .left
    )
    private let skeletonView = UISkeletonView(width: 80, height: 28)
    private let arrowImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FeedGroupButton {
    func configure(title: String?, isLoading: Bool) {
        groupTitleLabel.text = title
        groupTitleLabel.isHidden = isLoading
        skeletonView.isHidden = !isLoading

        if isLoading {
            skeletonView.startAnimating()
        } else {
            skeletonView.stopAnimating()
        }
    }
}

private extension FeedGroupButton {
    func setupUI() {
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = contentSpacing
        contentStackView.isUserInteractionEnabled = false

        arrowImageView.image = .icArrowUp.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = .gray8
        arrowImageView.contentMode = .scaleAspectFit
    }

    func setupLayout() {
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(groupTitleLabel)
        contentStackView.addArrangedSubview(skeletonView)
        contentStackView.addArrangedSubview(arrowImageView)

        contentStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(verticalPadding)
            $0.leading.equalToSuperview().inset(horizontalPadding)
            $0.trailing.lessThanOrEqualToSuperview().inset(horizontalPadding)
        }

        arrowImageView.snp.makeConstraints {
            $0.size.equalTo(iconSize)
        }
    }
}
