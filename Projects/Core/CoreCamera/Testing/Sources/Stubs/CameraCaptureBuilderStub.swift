//  CameraCaptureBuilderStub.swift
//  CoreCameraTesting
//
//  Created by 김동준 on 10/9/26.
//

import CoreCameraInterface
import SwiftUI
import UIKit

/// 소비 Demo가 결과·리소스를 주입하고 공통 대역은 선택·취소 UI만 제공합니다.
public struct CameraCaptureBuilderStub: CameraCaptureBuildable {
    private let captureResult: (@MainActor () -> CameraCaptureResult)?

    /// nil이면 취소 버튼만 표시합니다.
    public init(captureResult: (@MainActor () -> CameraCaptureResult)?) {
        self.captureResult = captureResult
    }

    @MainActor
    public func makeCameraViewController(
        source: CameraCaptureSource,
        isCropEnabled: Bool,
        cropAspectRatio: CGSize?,
        onEvent: @escaping (CameraCaptureEvent) -> Void,
        onComplete: @escaping (CameraCaptureResult) -> Void,
        onCancel: @escaping () -> Void
    ) -> UIViewController {
        UIHostingController(
            rootView: CameraCaptureStubView(
                onCapture: captureResult.map { result in { onComplete(result()) } },
                onCancel: onCancel
            ))
    }
}
