//
//  CustomTabBarView.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import SnapKit
import DesignSystem

final class CustomTabBarView: UIView {
    var onSelect: ((Int) -> Void)?

    private let tabs: [MainTab]
    private var itemViews: [CustomTabBarItemView] = []

    init(tabs: [MainTab]) {
        self.tabs = tabs
        super.init(frame: .zero)
        setupUI()
        setupLayout()
        updateSelection(index: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray2
        
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        return stackView
    }()
}

extension CustomTabBarView {
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
    func setupUI() {
        backgroundColor = UIColor.white
    }
    
    func setupLayout() {
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
