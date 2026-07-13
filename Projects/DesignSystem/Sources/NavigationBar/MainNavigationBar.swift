//
//  MainNavigationBar.swift
//  DesignSystem
//
//  Created by 김동준 on 7/5/26
//

import UIKit
import SnapKit

public final class MainNavigationBar: UIView {
    public var onUsersTap: (() -> Void)?
    public var onAlarmTap: (() -> Void)?

    private let contentView = UIView()
    private let logoImageView = UIImageView()
    private let buttonStackView = UIStackView()
    private let usersButton = UIButton(type: .system)
    private let alarmButton = UIButton(type: .system)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setUsersButtonVisible(_ isVisible: Bool) {
        usersButton.isHidden = !isVisible
    }
}

private extension MainNavigationBar {
    func setupUI() {
        backgroundColor = .systemWhite

        logoImageView.image = .imgModyLogo
        logoImageView.contentMode = .scaleAspectFit

        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fill
        buttonStackView.spacing = 12

        configureIconButton(usersButton, image: .icUsers, action: #selector(didTapUsersButton))
        configureIconButton(alarmButton, image: .icAlarm, action: #selector(didTapAlarmButton))
    }

    func setupLayout() {
        addSubview(contentView)
        contentView.addSubview(logoImageView)
        contentView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(usersButton)
        buttonStackView.addArrangedSubview(alarmButton)

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(
                UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
            )
        }

        logoImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        buttonStackView.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
        }

        [usersButton, alarmButton].forEach {
            $0.snp.makeConstraints {
                $0.size.equalTo(24)
            }
        }
    }

    func configureIconButton(
        _ button: UIButton,
        image: UIImage,
        action: Selector
    ) {
        button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .gray10
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    @objc func didTapUsersButton() {
        onUsersTap?()
    }

    @objc func didTapAlarmButton() {
        onAlarmTap?()
    }
}
