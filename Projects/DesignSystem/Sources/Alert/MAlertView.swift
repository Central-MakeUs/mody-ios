//
//  MAlertView.swift
//  DesignSystem
//

import SwiftUI

public struct MAlertView: View {
    private let title: String
    private let contents: String
    private let leadingButton: MAlertButton?
    private let trailingButton: MAlertButton?
    private let dismissOnBackgroundTap: Bool
    private let onDismiss: () -> Void

    public init(
        title: String,
        contents: String,
        leadingButton: MAlertButton? = nil,
        trailingButton: MAlertButton? = nil,
        dismissOnBackgroundTap: Bool = true,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.title = title
        self.contents = contents
        self.leadingButton = leadingButton
        self.trailingButton = trailingButton
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            Color.systemBlack
                .opacity(0.6)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    guard dismissOnBackgroundTap else { return }
                    onDismiss()
                }

            alertCard()
        }
        .greedyFrame()
    }
}

private extension MAlertView {
    func alertCard() -> some View {
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
