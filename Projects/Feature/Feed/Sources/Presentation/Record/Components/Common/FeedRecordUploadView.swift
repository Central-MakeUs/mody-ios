//
//  FeedRecordUploadView.swift
//  Feed
//
//  Created by 김동준 on 7/15/26.
//

import UIKit
import DesignSystem
import SnapKit

final class FeedRecordUploadView: UIControl {
    private let borderLayer = CAShapeLayer()
    private let contentStackView = UIStackView()
    private let iconImageView = UIImageView()
    private let titleLabel = MUILabel(
        text: "사진 업로드하기",
        style: .b3,
        color: .main0
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

    override func layoutSubviews() {
        super.layoutSubviews()

        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: 16
        ).cgPath
    }
}

private extension FeedRecordUploadView {
    func setupUI() {
        backgroundColor = .main4
        layer.cornerRadius = 16
        layer.masksToBounds = true

        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.main.cgColor
        borderLayer.lineWidth = 1
        borderLayer.lineDashPattern = [6, 6]
        layer.addSublayer(borderLayer)

        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.spacing = 8
        contentStackView.isUserInteractionEnabled = false

        iconImageView.image = .icGallery.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = .main0
        iconImageView.contentMode = .scaleAspectFit
    }

    func setupLayout() {
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(titleLabel)

        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }
    }
}
