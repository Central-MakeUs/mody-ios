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
            title: title,
            contents: message,
            trailingButton: MAlertButton("확인", action: primaryButtonAction)
        )
    }
    
    private var title: String {
        guard case let .serverError(_, _, fallback) = networkError else {
            return networkError.title
        }
        
        return fallback.title
    }
    
    private var message: String {
        guard case let .serverError(_, _, fallback) = networkError else {
            return networkError.message
        }
        
        return fallback.message
    }
}
