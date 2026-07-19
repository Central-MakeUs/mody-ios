//
//  CommonErrorAlertView.swift
//  Base
//
//  Created by 김동준 on 7/19/26.
//

import CommonDomain
import DesignSystem
import SwiftUI

public struct CommonErrorAlertView: View {
    private let networkError: NetworkError
    private let primaryButtonAction: () -> Void

    public init(
        _ networkError: NetworkError,
        primaryButtonAction: @escaping () -> Void
    ) {
        self.networkError = networkError
        self.primaryButtonAction = primaryButtonAction
    }

    public var body: some View {
        MAlertContentView(
            title: networkError.title,
            contents: networkError.message,
            trailingButton: MAlertButton("확인", action: primaryButtonAction)
        )
    }
}
