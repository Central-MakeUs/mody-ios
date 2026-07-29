//
//  FeedRecordFinishButton.swift
//  Feed
//
//  Created by 김동준 on 7/15/26.
//

import SwiftUI
import DesignSystem

struct FeedRecordFinishButtonView: View {
    let isEnabled: Bool
    let onTap: () -> Void

    var body: some View {
        MButton(
            "작성 완료",
            style: isEnabled ? .primary : .gray,
            isDisabled: !isEnabled,
            horizontalPadding: 0,
            verticalPadding: 13,
            maxWidth: .infinity,
            action: onTap
        )
    }
}
