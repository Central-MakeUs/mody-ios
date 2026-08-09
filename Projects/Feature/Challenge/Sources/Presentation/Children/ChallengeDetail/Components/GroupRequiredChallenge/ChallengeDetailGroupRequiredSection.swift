//
//  ChallengeDetailGroupRequiredSection.swift
//  Challenge
//
//  Created by 김동준 on 8/8/26.
//

import DesignSystem
import SwiftUI

struct ChallengeDetailGroupRequiredSection: View {
    private let status: ChallengeStepCountStatus?
    private let groupName: String?
    private let deviceWidth: CGFloat
    private let changeAction: () -> Void
    private let refreshAction: () -> Void

    init(
        status: ChallengeStepCountStatus?,
        groupName: String?,
        deviceWidth: CGFloat,
        changeAction: @escaping () -> Void,
        refreshAction: @escaping () -> Void
    ) {
        self.status = status
        self.groupName = groupName
        self.deviceWidth = deviceWidth
        self.changeAction = changeAction
        self.refreshAction = refreshAction
    }

    var body: some View {
        VStack(spacing: 0) {
            ChallengeDetailGroupRequiredTitleSection(
                status: status,
                groupName: groupName,
                changeAction: changeAction
            )
            .padding(.horizontal, 24)
            .padding(.top, 36)

            ChallengeDetailGroupRequiredProgressGauge(
                status: status,
                deviceWidth: deviceWidth
            )
            .padding(.top, 34)

            ChallengeDetailGroupRequiredStepCountSection(
                status: status,
                refreshAction: refreshAction
            )
            .padding(.top, 16)

            Color.gray2
                .height(1)
                .greedyWidth()
                .hPadding(24)
                .padding(.top, 20)
                .padding(.bottom, 24)
        }
        .background(Color.systemWhite)
    }
}
