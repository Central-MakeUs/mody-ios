//
//  NotificationListView.swift
//  Main
//
//  Created by 김동준 on 7/24/26.
//

import CoreNotificationInterface
import SwiftUI
import DesignSystem

struct NotificationListView: View {
    let notifications: [NotificationItem]
    let hasNext: Bool
    let onLoadNextPage: () -> Void
    
    init(
        notifications: [NotificationItem],
        hasNext: Bool,
        onLoadNextPage: @escaping () -> Void
    ) {
        self.notifications = notifications
        self.hasNext = hasNext
        self.onLoadNextPage = onLoadNextPage
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(notifications, id: \.notificationId) { notification in
                    NotificationRow(notification: notification)
                }

                if hasNext {
                    MLoadingIndicatorView()
                        .padding(.vertical, 20)
                        .onAppear {
                            onLoadNextPage()
                        }
                }
            }
        }
        .scrollIndicators(.visible)
    }
}
