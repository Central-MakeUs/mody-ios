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
        viewController.safeAreaRegions = []
        viewController.view.backgroundColor = .systemWhite
        viewController.modalPresentationStyle = .pageSheet

        if let sheetPresentationController = viewController.sheetPresentationController {
            let identifier = UISheetPresentationController.Detent.Identifier("groupSelect")

            sheetPresentationController.detents = [
                .custom(identifier: identifier) { [weak self, weak viewController] context in
                    guard let self, let viewController else { return 0 }

                    let fittingWidth = viewController.view.bounds.width > 0
                        ? viewController.view.bounds.width
                        : view.bounds.width
                    let contentHeight = viewController.sizeThatFits(
                        in: .init(
                            width: fittingWidth,
                            height: .greatestFiniteMagnitude
                        )
                    ).height
                    return min(
                        max(
                            0,
                            contentHeight - DeviceSizeManager.shared.bottomSafeAreaInset
                        ),
                        context.maximumDetentValue
                    )
                }
            ]
            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.preferredCornerRadius = 36
        }

        present(viewController, animated: true)
    }
}
