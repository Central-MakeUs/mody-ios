//
//  FeedWeekCalendarHeaderView.swift
//  Feed
//
//  Created by 김동준 on 7/14/26.
//

import UIKit
import DesignSystem
import SnapKit

final class FeedWeekCalendarHeaderView: UIView {
    var onPreviousWeekTap: (() -> Void)?
    var onNextWeekTap: (() -> Void)?

    private let titleLabel = MUILabel(
        style: .b3,
        color: .gray6,
        alignment: .left
    )
    private let previousButton = UIButton(type: .custom)
    private let nextButton = UIButton(type: .custom)
    private let buttonStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupActions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        title: String,
        canMovePrevious: Bool,
        canMoveNext: Bool
    ) {
        titleLabel.text = title
        configure(button: previousButton, isEnabled: canMovePrevious)
        configure(button: nextButton, isEnabled: canMoveNext)
    }
    
    func configure(
        button: UIButton,
        image: UIImage
    ) {
        var configuration = UIButton.Configuration.plain()
        configuration.image = image.withRenderingMode(.alwaysTemplate)
        configuration.contentInsets = .init(
            top: 8,
            leading: 0,
            bottom: 8,
            trailing: 0
        )
        button.configuration = configuration
        button.configurationUpdateHandler = { button in
            var configuration = button.configuration
            configuration?.baseForegroundColor = button.isEnabled ? .gray6 : .gray3
            button.configuration = configuration
        }
    }

    func configure(
        button: UIButton,
        isEnabled: Bool
    ) {
        button.isEnabled = isEnabled
        button.setNeedsUpdateConfiguration()
    }
}

private extension FeedWeekCalendarHeaderView {
    func setupUI() {
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.spacing = 8

        configure(
            button: previousButton,
            image: .icLeftArrow
        )
        configure(
            button: nextButton,
            image: .icRightArrow
        )
    }

    func setupLayout() {
        addSubview(titleLabel)
        addSubview(buttonStackView)

        buttonStackView.addArrangedSubview(previousButton)
        buttonStackView.addArrangedSubview(nextButton)

        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.lessThanOrEqualTo(buttonStackView.snp.leading).offset(-8)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-24)
        }

        [previousButton, nextButton].forEach { button in
            button.snp.makeConstraints {
                $0.width.equalTo(24)
            }
        }
    }

    func setupActions() {
        previousButton.addTarget(
            self,
            action: #selector(previousButtonTapped),
            for: .touchUpInside
        )
        nextButton.addTarget(
            self,
            action: #selector(nextButtonTapped),
            for: .touchUpInside
        )
    }

    @objc
    func previousButtonTapped() {
        onPreviousWeekTap?()
    }

    @objc
    func nextButtonTapped() {
        onNextWeekTap?()
    }
}
