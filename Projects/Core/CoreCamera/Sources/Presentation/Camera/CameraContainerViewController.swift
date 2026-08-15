//
//  CameraContainerViewController.swift
//  CoreCamera
//
//  Created by 김동준 on 7/20/26.
//

import CoreCameraInterface
import DesignSystem
import Photos
import PhotosUI
import SnapKit
import UIKit

final class CameraContainerViewController: UIViewController {
    static let previewMaxPixelSize = 2048

    private let initialSource: CameraCaptureSource
    let isCropEnabled: Bool
    let onComplete: (CameraCaptureResult) -> Void
    let onCancel: () -> Void
    let sessionController = CameraCaptureSessionController()
    let capturedPhotoProcessor: CameraCapturedPhotoProcessor

    private let previewView = CameraPreviewView()
    let selectedImageView = UIImageView()
    let closeButton = UIButton(type: .system)
    let bottomCameraShutterView = BottomCameraShutterView()
    let photoConfirmationContainerView = PhotoConfirmationContainerView()
    let roiOverlayView: ROIOverlayView

    var capturedPhoto: CameraCapturedPhoto?
    var photoLibraryLoadProgress: Progress?
    var photoLibraryLoadID: UUID?
    private var didPresentInitialPhotoLibrary = false

    init(
        initialSource: CameraCaptureSource,
        isCropEnabled: Bool = true,
        cropAspectRatio: CGSize? = nil,
        capturedPhotoProcessor: CameraCapturedPhotoProcessor,
        onComplete: @escaping (CameraCaptureResult) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initialSource = initialSource
        self.isCropEnabled = isCropEnabled
        self.roiOverlayView = ROIOverlayView(selectionAspectRatio: cropAspectRatio)
        self.capturedPhotoProcessor = capturedPhotoProcessor
        self.onComplete = onComplete
        self.onCancel = onCancel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        bindActions()

        previewView.configure(session: sessionController.session)
        if initialSource == .camera {
            sessionController.start()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard initialSource == .photoLibrary,
              !didPresentInitialPhotoLibrary else { return }
        didPresentInitialPhotoLibrary = true
        presentPhotoLibrary()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionController.cancelPendingCapture()
        sessionController.stop()
    }

    deinit {
        photoLibraryLoadProgress?.cancel()
        removeCapturedPhotoFile()
    }
}

private extension CameraContainerViewController {
    func setupUI() {
        view.backgroundColor = .systemBlack

        selectedImageView.contentMode = .scaleAspectFill
        selectedImageView.clipsToBounds = true
        selectedImageView.isHidden = true

        closeButton.setImage(UIImage.icMultiple, for: .normal)
        closeButton.tintColor = .gray10
        closeButton.contentHorizontalAlignment = .fill
        closeButton.contentVerticalAlignment = .fill

        photoConfirmationContainerView.isHidden = true
        roiOverlayView.isHidden = true
    }

    func setupLayout() {
        var subviews: [UIView] = [
            previewView,
            selectedImageView,
            closeButton,
            bottomCameraShutterView,
            photoConfirmationContainerView
        ]
        if isCropEnabled {
            subviews.insert(roiOverlayView, at: 2)
        }
        subviews.forEach {
            view.addSubview($0)
        }

        previewView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        selectedImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        if isCropEnabled {
            roiOverlayView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }

        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.trailing.equalToSuperview().inset(24)
            $0.size.equalTo(32)
        }

        bottomCameraShutterView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
            $0.height.equalTo(80)
        }

        photoConfirmationContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
            $0.height.equalTo(40)
        }
    }

    func bindActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        bottomCameraShutterView.onGalleryTap = { [weak self] in
            self?.presentPhotoLibrary()
        }
        bottomCameraShutterView.onCaptureTap = { [weak self] in
            self?.capturePhoto()
        }
        bottomCameraShutterView.onSwitchCameraTap = { [weak self] in
            self?.sessionController.switchCamera()
        }
        photoConfirmationContainerView.onRetakeTap = { [weak self] in
            self?.resetCapturedPhoto()
        }
        photoConfirmationContainerView.onUploadTap = { [weak self] in
            self?.completeCapture()
        }
    }
}
