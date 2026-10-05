//
//  MyPageDemoMediaStub.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import CoreCameraInterface
import CoreModyImageInterface
import DesignSystem
import SwiftUI
import UIKit

struct MyPageDemoImageStub: ImageUploadUseCaseProtocol, TemporaryImageFileUseCaseProtocol {
    private let scenario: MyPageScenario

    init(scenario: MyPageScenario = .overview) {
        self.scenario = scenario
    }

    func uploadImage(fileURL: URL, fileName: String, domain: ImageUploadDomain) async throws -> String {
        if scenario == .photoUploadFailure {
            throw NetworkError.networkUnavailable
        }
        return "demo-profile-image"
    }

    func saveImage(data: Data, fileName: String) throws -> TemporaryImageFile {
        TemporaryImageFile(fileURL: URL(fileURLWithPath: "/tmp/\(fileName)"), fileName: fileName, contentType: "image/jpeg")
    }

    func copyImage(at sourceURL: URL, fileName: String) throws -> TemporaryImageFile {
        TemporaryImageFile(fileURL: sourceURL, fileName: fileName, contentType: "image/jpeg")
    }

    func removeImage(at fileURL: URL) throws {}
    func removeExpiredImages(olderThan expirationInterval: TimeInterval) throws {}
}

struct MyPageDemoCameraStub: CameraCaptureBuildable {
    private let scenario: MyPageScenario

    init(scenario: MyPageScenario) {
        self.scenario = scenario
    }

    @MainActor
    func makeCameraViewController(
        source: CameraCaptureSource,
        isCropEnabled: Bool,
        cropAspectRatio: CGSize?,
        onEvent: @escaping (CameraCaptureEvent) -> Void,
        onComplete: @escaping (CameraCaptureResult) -> Void,
        onCancel: @escaping () -> Void
    ) -> UIViewController {
        UIHostingController(rootView: VStack {
            Spacer()
            if scenario != .photoCaptureCancel {
                MButton("데모 사진 선택") {
                    onComplete(
                        CameraCaptureResult(
                            originalFile: TemporaryImageFile(
                                fileURL: URL(fileURLWithPath: "/tmp/mypage-demo-profile.jpg"),
                                fileName: "mypage-demo-profile.jpg",
                                contentType: "image/jpeg"
                            ),
                            croppedPreviewImage: UIImage(systemName: "person.crop.circle") ?? UIImage(),
                            normalizedSelectionFrame: CGRect(x: 0, y: 0, width: 1, height: 1)
                        )
                    )
                }
                .padding(24)
            }
            MButton("데모 촬영 취소", action: onCancel)
                .padding(24)
        })
    }
}
