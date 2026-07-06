//
//  MNavigationBar.swift
//  DesignSystem
//
//  Created by 김동준 on 7/6/26.
//

import SwiftUI

public struct MNavigationBar: View {
    private let hasExitButton: Bool
    private let title: String?
    private let image: Image?
    private let onBackTap: (() -> Void)?
    private let onExitTap: (() -> Void)?

    public init(
        hasExitButton: Bool = false,
        title: String? = nil,
        image: Image? = nil,
        onBackTap: (() -> Void)? = nil,
        onExitTap: (() -> Void)? = nil
    ) {
        self.hasExitButton = hasExitButton
        self.title = title
        self.image = image
        self.onBackTap = onBackTap
        self.onExitTap = onExitTap
    }

    public var body: some View {
        HStack(spacing: 0) {
            navigationButton(
                image: .icLeftArrow,
                color: .gray8,
                action: onBackTap
            )
            
            if let image, let title {
                makeAvatarInfo(
                    image: image,
                    title: title
                )
                .padding(.leading, 8)
            } else {
                if let title {
                    MText(
                        title,
                        style: .b6,
                        color: .gray9,
                        alignment: .leading
                    )
                    .padding(.leading, 4)
                }
            }
            
            Spacer()

            if hasExitButton {
                navigationButton(
                    image: .icMultiple,
                    color: .gray8,
                    action: onExitTap
                )
            }
        }
        .hPadding(24)
        .navigationBarBackButtonHidden()
        .background(Color.systemWhite)
    }
}

private extension MNavigationBar {
    func navigationButton(
        image: Image,
        color: Color,
        action: (() -> Void)?
    ) -> some View {
        Button {
            action?()
        } label: {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(color)
        }
        .padding(.vertical, 12)
    }
}

private extension MNavigationBar {
    func makeAvatarInfo(image: Image, title: String) -> some View {
        HStack(spacing: 8) {
            image
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            
            MText(
                title,
                style: .b6,
                color: .gray9,
                alignment: .leading
            )
        }
    }
}
