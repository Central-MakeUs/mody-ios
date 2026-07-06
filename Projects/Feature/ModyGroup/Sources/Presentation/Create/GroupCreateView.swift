//
//  GroupCreateView.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct GroupCreateView: View {
    private let store: StoreOf<GroupCreateFeature>
    
    public init(store: StoreOf<GroupCreateFeature>) {
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

            Text("그룹 이름 정하기")
            
            Button("다음") {
                store.send(.nextButtonTapped)
            }
        }
        .navigationBarBackButtonHidden()
    }
}
