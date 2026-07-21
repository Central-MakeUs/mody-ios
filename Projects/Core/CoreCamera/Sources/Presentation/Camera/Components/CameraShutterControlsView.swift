//
//  CameraShutterControlsView.swift
//  CoreCamera
//
//  Created by 김동준 on 7/20/26.
//

import DesignSystem
import SnapKit
import UIKit

final class CameraShutterControlsView: UIView {
    var onGalleryTap: (() -> Void)?
    var onCaptureTap: (() -> Void)?
    var onSwitchCameraTap: (() -> Void)?

    private let galleryButton = UIButton(type: .custom)
    private let captureButton = UIButton(type: .custom)
    private let captureInnerCircleView = UIView()
    private let switchCameraButton = UIButton(type: .custom)

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

private extension CameraShutterControlsView {
    func setupUI() {
        [galleryButton, switchCameraButton].forEach {
            $0.backgroundColor = .gray7
            $0.layer.cornerRadius = 28
        }

        galleryButton.setImage(
            UIImage.icGallery.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        galleryButton.tintColor = .systemWhite

        switchCameraButton.setImage(
            UIImage.icExchange.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        switchCameraButton.tintColor = .systemWhite

        captureButton.backgroundColor = .clear
        captureButton.layer.cornerRadius = 40
        captureButton.layer.borderColor = UIColor.systemWhite.cgColor
        captureButton.layer.borderWidth = 5

        captureInnerCircleView.backgroundColor = .systemWhite
        captureInnerCircleView.layer.cornerRadius = 32
        captureInnerCircleView.isUserInteractionEnabled = false

        galleryButton.addTarget(self, action: #selector(galleryTapped), for: .touchUpInside)
        captureButton.addTarget(self, action: #selector(captureTapped), for: .touchUpInside)
        switchCameraButton.addTarget(self, action: #selector(switchCameraTapped), for: .touchUpInside)
    }

    func setupLayout() {
        [galleryButton, captureButton, switchCameraButton].forEach {
            addSubview($0)
        }
        captureButton.addSubview(captureInnerCircleView)

        captureButton.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.size.equalTo(80)
        }

        captureInnerCircleView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(64)
        }

        galleryButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalTo(captureButton)
            $0.size.equalTo(56)
        }

        switchCameraButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(captureButton)
            $0.size.equalTo(56)
        }
    }

    @objc func galleryTapped() {
        onGalleryTap?()
    }

    @objc func captureTapped() {
        onCaptureTap?()
    }

    @objc func switchCameraTapped() {
        onSwitchCameraTap?()
    }
}
