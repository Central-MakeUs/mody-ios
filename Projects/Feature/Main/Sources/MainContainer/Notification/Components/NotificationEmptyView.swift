//
//  NotificationEmptyView.swift
//  Main
//
//  Created by 김동준 on 7/24/26.
//

import SwiftUI
import DesignSystem

struct NotificationEmptyView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image.imgModyNotificationEmpty
                .padding(.bottom, 24)

            contentsView
            
            Spacer()
        }
    }
    
    private var contentsView: some View {
        VStack(spacing: 4) {
            MText(
                "새로운 알림이 없어요.",
                style: .b3,
                color: .gray10
            )
            
            MText(
                "새로운 소식이 생기면 여기에서 알려드릴게요.",
                style: .b7,
                color: .gray6
            )
        }
    }
}
