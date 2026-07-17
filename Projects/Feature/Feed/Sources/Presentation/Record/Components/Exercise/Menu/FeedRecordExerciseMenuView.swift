//
//  FeedRecordExerciseMenuView.swift
//  Feed
//
//  Created by 김동준 on 7/15/26.
//

import UIKit
import DesignSystem
import SnapKit

final class FeedRecordExerciseMenuView: UIView {
    var onSelect: ((FeedExerciseType) -> Void)?

    private let contentContainerView = UIView()
    private let stackView = UIStackView()
    private var rows: [FeedExerciseType: FeedRecordExerciseMenuRow] = [:]

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

        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 12, height: 12)
        ).cgPath
    }

    func configure(selectedType: FeedExerciseType?) {
        rows.forEach { type, row in
            row.configure(isSelected: type == selectedType)
        }
    }
}

private extension FeedRecordExerciseMenuView {
    func setupUI() {
        backgroundColor = .clear
        layer.shadowColor = UIColor.systemBlack.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 2, height: 2)

        contentContainerView.backgroundColor = .systemWhite
        contentContainerView.layer.cornerRadius = 12
        contentContainerView.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        contentContainerView.layer.masksToBounds = true

        stackView.axis = .vertical
        stackView.spacing = 0

        FeedExerciseType.allCases.forEach { type in
            let row = FeedRecordExerciseMenuRow(type: type)
            row.addAction(UIAction { [weak self] _ in
                self?.onSelect?(type)
            }, for: .touchUpInside)
            rows[type] = row
            stackView.addArrangedSubview(row)
        }
    }

    func setupLayout() {
        addSubview(contentContainerView)
        contentContainerView.addSubview(stackView)

        contentContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
