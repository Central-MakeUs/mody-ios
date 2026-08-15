//
//  SplashView.swift
//  Splash
//
//  Created by 김동준 on 6/25/26
//

import SwiftUI
import Base
import CommonDomain
import ComposableArchitecture
import DesignSystem

public struct SplashView: View {
    @Environment(\.openURL) private var openURL
    private let store: StoreOf<SplashFeature>
    
    public init(store: StoreOf<SplashFeature>) {
        self.store = store
    }
    
    public var body: some View {
        splashBody
            .onAppear { store.send(.onAppear) }
            .mLoading(isPresent: store.isLoading)
            .mAlert(store.scope(state: \.alertState, action: \.alertAction)) {
                alertView
            }
    }
    
    private var splashBody: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                DeviceSizeManager.shared.update(
                    bottomSafeAreaInset: proxy.safeAreaInsets.bottom
                )
            }
        }
    }
}

private extension SplashView {
    @ViewBuilder
    var alertView: some View {
        if let alertCase = store.alertCase {
            switch alertCase {
            case let .error(networkError):
                CommonErrorAlertView(networkError) {
                    store.send(.alertAction(.dismiss))
                }
            case .forceUpdate:
                updateAlertView(
                    title: "업데이트가 필요해요",
                    contents: "원활한 모디 서비스 이용을 위해 최신 버전으로 업데이트해 주세요."
                )
            case .minimumSupportedVersion:
                updateAlertView(
                    title: "지원이 종료된 버전이에요",
                    contents: "모디를 계속 이용하려면 최신 버전으로 업데이트해 주세요."
                )
            case let .notice(noticePopupInfo):
                NoticePopupView(info: noticePopupInfo) {
                    store.send(.noticeConfirmButtonTapped)
                }
            }
        }
    }

    func updateAlertView(
        title: String,
        contents: String
    ) -> some View {
        MAlertContentView(
            title: title,
            contents: contents,
            trailingButton: MAlertButton("업데이트") {
                openAppStore(urlString: store.appStoreURLString)
            }
        )
    }

    func openAppStore(urlString: String) {
        guard let fallbackURL = URL(string: "https://apps.apple.com/kr/") else {
            return
        }

        let appStoreURL = appStoreURL(from: urlString) ?? fallbackURL
        openURL(appStoreURL)
    }

    func appStoreURL(from urlString: String) -> URL? {
        let trimmedURLString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let url = URL(string: trimmedURLString),
              url.scheme?.lowercased() == "https",
              url.host?.lowercased() == "apps.apple.com" else {
            return nil
        }

        return url
    }
}
