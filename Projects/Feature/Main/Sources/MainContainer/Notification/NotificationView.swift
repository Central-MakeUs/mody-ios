//
//  NotificationView.swift
//  Main
//
//  Created by 김동준 on 7/24/26.
//

import Base
import ComposableArchitecture
import DesignSystem
import SwiftUI

struct NotificationView: View {
    @Bindable private var store: StoreOf<NotificationFeature>

    init(store: StoreOf<NotificationFeature>) {
        self.store = store
    }

    var body: some View {
        notificationBody
            .background(Color.systemWhite)
            .onAppear { store.send(.onAppear) }
            .mLoading(isPresent: store.isLoading)
            .mAlert(store.scope(state: \.alertState, action: \.alertAction)) {
                alertView
            }
    }

    private var notificationBody: some View {
        VStack(spacing: 0) {
            MNavigationBar(
                title: "알림",
                onBackTap: { store.send(.backButtonTapped) }
            )

            contentsBody
        }
    }
    
    @ViewBuilder
    private var contentsBody: some View {
        if store.isNotificationEmpty {
            NotificationEmptyView()
        } else {
            NotificationListView(
                notifications: store.notifications,
                hasNext: store.hasNext,
                onLoadNextPage: { store.send(.loadNextPage) }
            )
        }
    }
}

private extension NotificationView {
    @ViewBuilder
    var alertView: some View {
        if let alertCase = store.alertCase {
            switch alertCase {
            case let .error(networkError):
                CommonErrorAlertView(networkError) {
                    store.send(.alertAction(.dismiss))
                }
            }
        }
    }
}
