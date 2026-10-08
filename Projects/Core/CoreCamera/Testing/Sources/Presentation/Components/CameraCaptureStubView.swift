//  CameraCaptureStubView.swift
//  CoreCameraTesting
//
//  Created by 김동준 on 10/9/26.
//

import DesignSystem
import SwiftUI

struct CameraCaptureStubView: View {
    private let onCapture: (() -> Void)?
    private let onCancel: () -> Void

    init(onCapture: (() -> Void)?, onCancel: @escaping () -> Void) {
        self.onCapture = onCapture
        self.onCancel = onCancel
    }

    var body: some View {
        VStack {
            Spacer()
            if let onCapture {
                MButton("데모 사진 선택", action: onCapture)
                    .padding(24)
            }
            MButton("데모 촬영 취소", action: onCancel)
                .padding(24)
        }
    }
}
