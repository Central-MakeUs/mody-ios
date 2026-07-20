//
//  SignInView.swift
//  SignIn
//
//  Created by 김동준 on 6/25/26
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct SignInView: View {
    private let store: StoreOf<SignInFeature>
    
    public init(store: StoreOf<SignInFeature>) {
        self.store = store
    }
    
    public var body: some View {
        signInBody
            .onAppear { store.send(.onAppear) }
            .mLoading(isPresent: store.isLoading)
    }
}

private extension SignInView {
    var signInBody: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: proxy.size.height * 0.28)
                
                titleSection
                
                Spacer()
                
                loginButtonSection
                    .hPadding(24)
                    .padding(.bottom, 62)
            }
            .greedyFrame()
            .background(Color.systemWhite)
        }
    }
}

private extension SignInView {
    var titleSection: some View {
        VStack(spacing: 16) {
            Image.imgModyAppIcon
                .resizable()
                .scaledToFit()
                .frame(78, 78)
            
            titleText
        }
    }
    
    var titleText: some View {
        MText(
            "친구와 함께 만드는\n다이어트 습관",
            style: .h1,
            color: .gray10,
            lineLimit: 2
        )
    }
}

private extension SignInView {
    var loginButtonSection: some View {
        VStack(spacing: 12) {
            socialLoginButton(.kakao) {
                store.send(.kakaoLoginButtonTapped)
            }
            
            socialLoginButton(.apple) {
                store.send(.appleLoginButtonTapped)
            }
        }
    }
    
    func socialLoginButton(
        _ type: SocialLoginButtonType,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            socialButtonContent(type)
                .padding(.vertical, type.verticalPadding)
                .greedyWidth()
                .background(type.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    func socialButtonContent(_ type: SocialLoginButtonType) -> some View {
        HStack(spacing: 12) {
            type.image
            
            MText(
                type.title,
                style: .b6,
                color: type.foregroundColor
            )
        }
    }
}

private enum SocialLoginButtonType {
    case kakao
    case apple
    
    var image: Image {
        switch self {
        case .kakao: .icKakao
        case .apple: .icApple
        }
    }
    
    var title: String {
        switch self {
        case .kakao: "카카오로 시작하기"
        case .apple: "Apple로 시작하기"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .kakao: .kakaoBackground
        case .apple: .systemBlack
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .kakao: .systemBlack
        case .apple: .systemWhite
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .kakao: 13
        case .apple: 15
        }
    }
}
