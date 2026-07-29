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

            MAlertContentView(
                title: title,
                contents: contents,
                leadingButton: leadingButton,
                trailingButton: trailingButton
            )
        }
        .greedyFrame()
    }
}
