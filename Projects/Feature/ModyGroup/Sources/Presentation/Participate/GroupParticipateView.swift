//
//  GroupParticipateView.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct GroupParticipateView: View {
    private let store: StoreOf<GroupParticipateFeature>
    
    public init(store: StoreOf<GroupParticipateFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            if store.showsBackButton {
                HStack {
                    Button {
                        store.send(.backButtonTapped)
                    } label: {
                        Image.icLeftArrow
                            .renderingMode(.template)
                            .foregroundStyle(Color.gray10)
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("뒤로가기")
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
            }

            Text(store.showSignUpDoneContents ? "회원가입이 완료되었습니다" : "그룹에 참여해보세요")
            
            Button("참여하기") {
                store.send(.participateButtonTapped)
            }
            
            Button("생성하기") {
                store.send(.createButtonTapped)
            }
        }
        .navigationBarBackButtonHidden()
    }
}
