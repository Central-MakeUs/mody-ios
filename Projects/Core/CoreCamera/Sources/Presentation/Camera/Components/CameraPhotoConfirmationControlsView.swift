//
//  CameraPhotoConfirmationControlsView.swift
//  CoreCamera
//
//  Created by 김동준 on 7/20/26.
//

import DesignSystem
import SnapKit
import UIKit

final class CameraPhotoConfirmationControlsView: UIView {
    var onRetakeTap: (() -> Void)?
    var onUploadTap: (() -> Void)?

    private let retakeButton = CameraTextButton(
        title: "다시 찍기",
        backgroundColor: .gray10,
        textColor: .systemWhite
    )
    
    private let uploadButton = CameraTextButton(
        title: "업로드",
        backgroundColor: .main,
        textColor: .gray10,
        trailingImage: .icCheck,
        trailingImageBackgroundColor: .gray10,
        trailingImageTintColor: .main
    )

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

private extension CameraPhotoConfirmationControlsView {
    func setupUI() {
        retakeButton.addTarget(self, action: #selector(retakeTapped), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(uploadTapped), for: .touchUpInside)
    }

    func setupLayout() {
        [retakeButton, uploadButton].forEach {
            addSubview($0)
        }

        retakeButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(40)
        }

        uploadButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(40)
        }
    }

    @objc func retakeTapped() {
        onRetakeTap?()
    }

    @objc func uploadTapped() {
        onUploadTap?()
    }
}
