//
//  FeedRecordMenuView.swift
//  Feed
//
//  Created by 김동준 on 7/29/26.
//

import DesignSystem
import SnapKit
import UIKit

final class FeedRecordMenuView: UIView {
    var onSelect: ((FeedRecordMenu) -> Void)?

    private let stackView = UIStackView()
    private var menus: [FeedRecordMenu] = []

    var hasMenus: Bool {
        !menus.isEmpty
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 88, height: 34 * CGFloat(menus.count))
    }

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
            cornerRadius: 8
        ).cgPath
    }

    func configure(menus: [FeedRecordMenu]) {
        self.menus = menus

        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        menus.forEach { menu in
            stackView.addArrangedSubview(makeMenuButton(menu))
        }

        invalidateIntrinsicContentSize()
    }
}

private extension FeedRecordMenuView {
    func setupUI() {
        backgroundColor = .systemWhite
        layer.cornerRadius = 8
        layer.borderColor = UIColor.gray1.cgColor
        layer.borderWidth = 1
        layer.shadowColor = UIColor.gray6.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 5

        stackView.axis = .vertical
        stackView.spacing = 0
    }

    func setupLayout() {
        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func makeMenuButton(_ menu: FeedRecordMenu) -> UIButton {
        let button = UIButton(type: .custom)
        button.setAttributedTitle(
            ModyTypography.c1.token.attributedString(
                menu.title,
                color: menu.titleColor,
                alignment: .center
            ),
            for: .normal
        )
        button.addAction(
            UIAction { [weak self] _ in
                self?.onSelect?(menu)
            },
            for: .touchUpInside
        )
        button.snp.makeConstraints {
            $0.height.equalTo(34)
        }
        return button
    }
}

private extension FeedRecordMenu {
    var title: String {
        switch self {
        case .report:
            return "신고"
        case .delete:
            return "삭제"
        }
    }

    var titleColor: UIColor {
        switch self {
        case .report:
            return .gray10
        case .delete:
            return .systemError
        }
    }
}
