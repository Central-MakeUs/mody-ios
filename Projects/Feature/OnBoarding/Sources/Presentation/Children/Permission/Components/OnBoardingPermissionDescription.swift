//
//  OnBoardingPermissionDescription.swift
//  OnBoarding
//
//  Created by 김동준 on 7/20/26.
//

import DesignSystem
import SwiftUI

struct OnBoardingPermissionDescription: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MText(
                "MODY를 이용하기 위해\n다음 접근 권한 허용이 필요해요",
                style: .h2,
                color: .gray10,
                lineLimit: 2,
                alignment: .leading
            )

            MText(
                "선택 권한을 허용하지 않아도 사용할 수 있어요.\n해당 기능을 이용할 때 다시 요청드릴게요.",
                style: .b7,
                color: .gray6,
                lineLimit: 2,
                alignment: .leading
            )
        }
        .greedyWidth(.leading)
    }
}
