//
//  HealthDataSettingsStepView.swift
//  MyPage
//
//  Created by 김동준 on 8/17/26.
//

import DesignSystem
import SwiftUI

struct HealthDataSettingsStepView: View {
    private let step: Int

    init(step: Int) {
        self.step = step
    }

    var body: some View {
        VStack(spacing: 0) {
            stepBadge

            MText(
                instruction,
                style: .b2,
                color: .gray10
            )
            .padding(.top, 16)

            stepImage
                .resizable()
                .scaledToFit()
                .frame(width: 282, height: 368)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.top, 30)
        }
    }
}

private extension HealthDataSettingsStepView {
    var stepBadge: some View {
        MText(
            "STEP \(step)",
            style: .c2,
            color: .systemWhite
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.gray9)
        .clipShape(Capsule())
    }

    var instruction: String {
        switch step {
        case 1:
            return "건강 앱에서 ‘프로필’을 클릭해주세요"
        case 2:
            return "‘앱’을 클릭해주세요"
        case 3:
            return "‘MODY’설정으로 들어가주세요"
        default:
            return "‘걸음수’를 허용해주세요"
        }
    }

    var stepImage: Image {
        switch step {
        case 1:
            return .imgHealthSetting1
        case 2:
            return .imgHealthSetting2
        case 3:
            return .imgHealthSetting3
        default:
            return .imgHealthSetting4
        }
    }
}
