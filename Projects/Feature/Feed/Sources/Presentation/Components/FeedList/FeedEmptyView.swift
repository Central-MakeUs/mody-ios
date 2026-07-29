//
//  FeedEmptyView.swift
//  Feed
//
//  Created by 김동준 on 7/21/26
//

import UIKit
import DesignSystem
import SnapKit
import CommonDomain

final class FeedEmptyView: UIView {
    private let contentStackView = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = MUILabel(
        text: "오늘 피드를 올린 분이 없어요",
        style: .b3,
        color: .gray10
    )
    private let descriptionLabel = MUILabel(
        text: "콕찌르기를 통해 알려주세요!",
        style: .b7,
        color: .gray6
    )
    private let nudgeButton = UIButton(type: .system)

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

private extension FeedEmptyView {
    func setupUI() {
        backgroundColor = .systemWhite

        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.spacing = 24

        imageView.image = .imgFeedEmpty
        imageView.contentMode = .scaleAspectFit

        var configuration = UIButton.Configuration.filled()
        configuration.attributedTitle = AttributedString(
            ModyTypography.b6.token.attributedString(
                "콕 찌르기 하러 가기",
                color: .gray10
            )
        )
        configuration.baseBackgroundColor = .main
        configuration.background.cornerRadius = 8
        configuration.contentInsets = .init(top: 9, leading: 8, bottom: 9, trailing: 8)
        nudgeButton.configuration = configuration

        let isPhaseOne = PhaseManager.shared.isPhaseOne
        descriptionLabel.isHidden = isPhaseOne
        nudgeButton.isHidden = isPhaseOne
    }

    func setupLayout() {
        addSubview(contentStackView)

        let labelStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        labelStackView.axis = .vertical
        labelStackView.alignment = .center
        labelStackView.spacing = 4

        contentStackView.addArrangedSubview(imageView)
        contentStackView.addArrangedSubview(labelStackView)
        contentStackView.addArrangedSubview(nudgeButton)

        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        imageView.snp.makeConstraints {
            $0.width.lessThanOrEqualToSuperview()
        }
    }
}
