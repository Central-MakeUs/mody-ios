//
//  HealthDataSettingsPageIndicator.swift
//  MyPage
//
//  Created by 김동준 on 8/17/26.
//

import DesignSystem
import SwiftUI

struct HealthDataSettingsPageIndicator: View {
    private let selectedStep: Int

    init(selectedStep: Int) {
        self.selectedStep = selectedStep
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...4, id: \.self) { step in
                Capsule()
                    .fill(step == selectedStep ? Color.main : Color.gray2)
                    .frame(
                        width: step == selectedStep ? 20 : 8,
                        height: 8
                    )
            }
        }
    }
}
