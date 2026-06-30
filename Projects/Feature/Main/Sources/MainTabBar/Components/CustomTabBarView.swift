//
//  CustomTabBarView.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import SnapKit

final class CustomTabBarView: UIView {
    var onSelect: ((Int) -> Void)?

    private let tabs: [MainTab]
    private var itemViews: [CustomTabBarItemView] = []
    private let dividerView = UIView()

    init(tabs: [MainTab]) {
        self.tabs = tabs
        super.init(frame: .zero)
        configureLayout()
        updateSelection(index: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateSelection(index: Int) {
        itemViews.enumerated().forEach { itemIndex, itemView in
            itemView.configure(
                tab: tabs[itemIndex],
                isSelected: itemIndex == index
            )
        }
    }
}

private extension CustomTabBarView {
    func configureLayout() {
        backgroundColor = UIColor.white

        dividerView.backgroundColor = UIColor.red

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        addSubview(dividerView)
        addSubview(stackView)

        dividerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(MainTabBarConstants.dividerHeight)
        }

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(MainTabBarConstants.dividerHeight)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(MainTabBarConstants.height - MainTabBarConstants.dividerHeight)
        }

        tabs.enumerated().forEach { index, tab in
            let itemView = CustomTabBarItemView()
            itemView.configure(tab: tab, isSelected: false)
            itemView.onTap = { [weak self] in
                self?.onSelect?(index)
            }

            itemViews.append(itemView)
            stackView.addArrangedSubview(itemView)
        }
    }
}
