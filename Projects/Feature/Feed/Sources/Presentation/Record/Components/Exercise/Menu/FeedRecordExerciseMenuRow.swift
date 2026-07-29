//
//  FeedRecordExerciseMenuRow.swift
//  Feed
//
//  Created by 김동준 on 7/16/26.
//

import UIKit
import DesignSystem
import SnapKit

final class FeedRecordExerciseMenuRow: UIControl {
    private let type: FeedExerciseType
    private let titleLabel = MUILabel(
        style: .b4,
        color: .gray10,
        alignment: .left
    )

    init(type: FeedExerciseType) {
        self.type = type
        super.init(frame: .zero)
        titleLabel.text = type.name
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(isSelected: Bool) {
        backgroundColor = isSelected ? .main4 : .systemWhite
    }
}

private extension FeedRecordExerciseMenuRow {
    func setupLayout() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.top.bottom.equalToSuperview().inset(12)
        }
    }
}
