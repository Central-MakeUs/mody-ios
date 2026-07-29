//
//  OnBoardingPermissionView.swift
//  OnBoarding
//
//  Created by 김동준 on 7/20/26.
//

import DesignSystem
import SwiftUI

struct OnBoardingPermissionView: View {
    let isHealthPermissionVisible: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                OnBoardingPermissionDescription()
                    .padding(.top, 72)

                permissionRows
                    .padding(.top, 48)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }
}

private extension OnBoardingPermissionView {
    var permissionRows: some View {
        VStack(spacing: 24) {
            OnBoardingPermissionRow(
                icon: Image.icAlarm,
                title: "알림 (선택)",
                description: "버디 인증, 응원 댓글, 챌린지 달성 소식 받기"
            )

            OnBoardingPermissionRow(
                icon: Image.icCamera,
                title: "카메라 (선택)",
                description: "오늘의 식사와 운동을 사진으로 기록"
            )

            OnBoardingPermissionRow(
                icon: Image.icGallery,
                title: "사진 (선택)",
                description: "갤러리에서 식단·운동 사진을 바로 불러오기"
            )

            if isHealthPermissionVisible {
                OnBoardingPermissionRow(
                    icon: Image.icExercise,
                    title: "건강 정보 (선택)",
                    description: "걸음 수 챌린지"
                )
            }
        }
    }
}
