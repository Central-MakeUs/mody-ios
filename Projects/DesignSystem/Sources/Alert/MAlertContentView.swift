//  MAlertContentView.swift
//  DesignSystem
//
//  Created by 김동준 on 7/19/26.
//

import SwiftUI

public struct MAlertContentView: View {
    private let title: String
    private let contents: String
    private let leadingButton: MAlertButton?
    private let trailingButton: MAlertButton?

    public init(
        title: String,
        contents: String,
        leadingButton: MAlertButton? = nil,
        trailingButton: MAlertButton? = nil
    ) {
        self.title = title
        self.contents = contents
        self.leadingButton = leadingButton
        self.trailingButton = trailingButton
    }

    public var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                MText(
                    title,
                    style: .b2,
                    color: .gray10,
                    lineLimit: 1
                )

                MText(
                    contents,
                    style: .c2,
                    color: .gray6,
                    lineLimit: 2
                )
            }

            if leadingButton != nil || trailingButton != nil {
                HStack(spacing: 12) {
                    if let leadingButton {
                        alertButton(leadingButton)
                    }

                    if let trailingButton {
                        alertButton(trailingButton)
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 28)
        .greedyWidth()
        .background(Color.systemWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .hPadding(36)
    }
}

private extension MAlertContentView {
    func alertButton(_ button: MAlertButton) -> some View {
        Button {
            button.perform()
        } label: {
            MText(
                button.title,
                style: .b6,
                color: button.style.textColor
            )
            .frame(maxWidth: .infinity)
            .vPadding(9)
            .background(button.style.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
