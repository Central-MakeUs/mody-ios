//
//  CameraRotationControlsView.swift
//  CoreCamera
//
//  Created by 김동준 on 9/19/26.
//

import DesignSystem
import SnapKit
import UIKit

final class CameraRotationControlsView: UIView {
    var onRotateLeftTap: (() -> Void)?
    var onRotateRightTap: (() -> Void)?

    private let rotateLeftButton = UIButton(type: .system)
    private let rotateRightButton = UIButton(type: .system)

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

private extension CameraRotationControlsView {
    func setupUI() {
        configureButton(rotateLeftButton, systemName: "rotate.left")
        configureButton(rotateRightButton, systemName: "rotate.right")

        rotateLeftButton.addTarget(
            self,
            action: #selector(rotateLeftTapped),
            for: .touchUpInside
        )
        rotateRightButton.addTarget(
            self,
            action: #selector(rotateRightTapped),
            for: .touchUpInside
        )
    }

    func setupLayout() {
        [rotateLeftButton, rotateRightButton].forEach {
            addSubview($0)
        }

        rotateLeftButton.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.size.equalTo(32)
        }
        rotateRightButton.snp.makeConstraints {
            $0.leading.equalTo(rotateLeftButton.snp.trailing).offset(12)
            $0.top.bottom.trailing.equalToSuperview()
            $0.size.equalTo(32)
        }
    }

    func configureButton(
        _ button: UIButton,
        systemName: String
    ) {
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = .systemWhite
        button.backgroundColor = .gray10
        button.layer.cornerRadius = 8
    }

    @objc func rotateLeftTapped() {
        onRotateLeftTap?()
    }

    @objc func rotateRightTapped() {
        onRotateRightTap?()
    }
}
