//
//  CameraTextButton.swift
//  CoreCamera
//
//  Created by 김동준 on 7/21/26.
//

import UIKit
import DesignSystem
import SnapKit

final class CameraTextButton: UIControl {
    private let contentStackView = UIStackView()
    private let titleLabel: MUILabel
    private let trailingImageContainerView = UIView()
    private let imageView = UIImageView()
    private let trailingImage: UIImage?
    private let trailingImageBackgroundColor: UIColor?
    private let trailingImageTintColor: UIColor

    init(
        title: String,
        backgroundColor: UIColor,
        textColor: UIColor,
        trailingImage: UIImage? = nil,
        trailingImageBackgroundColor: UIColor? = nil,
        trailingImageTintColor: UIColor = .gray10
    ) {
        self.titleLabel = MUILabel(text: title, style: .b6, color: textColor)
        self.trailingImage = trailingImage
        self.trailingImageBackgroundColor = trailingImageBackgroundColor
        self.trailingImageTintColor = trailingImageTintColor
        super.init(frame: .zero)

        self.backgroundColor = backgroundColor
        setupUI()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CameraTextButton {
    func setupUI() {
        layer.cornerRadius = 8

        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = 6
        contentStackView.isUserInteractionEnabled = false

        guard let trailingImage else { return }
        trailingImageContainerView.backgroundColor = trailingImageBackgroundColor
        trailingImageContainerView.layer.cornerRadius = 10
        trailingImageContainerView.clipsToBounds = true
        trailingImageContainerView.isUserInteractionEnabled = false

        imageView.image = trailingImage.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = trailingImageTintColor
        imageView.contentMode = .scaleAspectFit
    }

    func setupLayout() {
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)

        if trailingImage != nil {
            let imageSize = trailingImageBackgroundColor == nil ? 20 : 14

            contentStackView.addArrangedSubview(trailingImageContainerView)
            trailingImageContainerView.addSubview(imageView)
            trailingImageContainerView.snp.makeConstraints {
                $0.size.equalTo(20)
            }
            imageView.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.size.equalTo(imageSize)
            }
        }

        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
