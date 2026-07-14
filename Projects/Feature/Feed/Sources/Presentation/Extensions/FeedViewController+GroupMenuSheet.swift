//
//  FeedViewController+GroupMenuSheet.swift
//  Feed
//
//  Created by 김동준 on 7/14/26.
//

import SwiftUI
import CommonDomain

extension FeedViewController {
    func presentGroupMenuSheet(
        groupList: [GroupModel],
        selectedGroup: GroupModel,
        onGroupSelect: @escaping (GroupModel) -> Void,
        onAddGroupTap: @escaping () -> Void
    ) {
        guard presentedViewController == nil else { return }

        let viewController = UIHostingController(
            rootView: FeedGroupSelectSheetView(
                groupList: groupList,
                selectedGroup: selectedGroup,
                onGroupSelect: { [weak self] group in
                    self?.dismiss(animated: true) {
                        onGroupSelect(group)
                    }
                },
                onAddGroupTap: { [weak self] in
                    self?.dismiss(animated: true) {
                        onAddGroupTap()
                    }
                }
            )
        )
        viewController.view.backgroundColor = .systemWhite
        viewController.modalPresentationStyle = .pageSheet

        if let sheetPresentationController = viewController.sheetPresentationController {
            let identifier = UISheetPresentationController.Detent.Identifier("groupSelect")
            sheetPresentationController.detents = [
                .custom(identifier: identifier) { _ in
                    407
                }
            ]
            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.preferredCornerRadius = 36
        }

        present(viewController, animated: true)
    }
}
