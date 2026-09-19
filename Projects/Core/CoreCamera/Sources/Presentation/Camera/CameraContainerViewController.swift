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
    let onEvent: (CameraCaptureEvent) -> Void
    let onComplete: (CameraCaptureResult) -> Void
    let onCancel: () -> Void
    let sessionController = CameraCaptureSessionController()
    let capturedPhotoProcessor: CameraCapturedPhotoProcessor

    let previewView = CameraPreviewView()
    let selectedImageView = UIImageView()
    let closeButton = UIButton(type: .system)
    let rotationControlsView = CameraRotationControlsView()
    private let topControlsStackView = UIStackView()
    private let topControlsSpacerView = UIView()
    let bottomCameraShutterView = BottomCameraShutterView()
    let photoConfirmationContainerView = PhotoConfirmationContainerView()
    let roiOverlayView: ROIOverlayView

    var capturedPhoto: CameraCapturedPhoto?
    var imageRotation: CameraImageRotation = .zero
    var rotatedPreviewImage: UIImage?
    var isRotatingPhoto = false
    var photoLibraryLoadProgress: Progress?
    var photoLibraryLoadID: UUID?
    private var didPresentInitialPhotoLibrary = false

    init(
        initialSource: CameraCaptureSource,
        isCropEnabled: Bool = true,
        cropAspectRatio: CGSize? = nil,
        capturedPhotoProcessor: CameraCapturedPhotoProcessor,
        onEvent: @escaping (CameraCaptureEvent) -> Void,
        onComplete: @escaping (CameraCaptureResult) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initialSource = initialSource
        self.isCropEnabled = isCropEnabled
        self.roiOverlayView = ROIOverlayView(selectionAspectRatio: cropAspectRatio)
        self.capturedPhotoProcessor = capturedPhotoProcessor
        self.onEvent = onEvent
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateROISelectableFrame()
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

    isolated deinit {
        photoLibraryLoadProgress?.cancel()
        removeCapturedPhotoFile()
    }
}

private extension CameraContainerViewController {
    func setupUI() {
        view.backgroundColor = .systemBlack

        selectedImageView.contentMode = .scaleAspectFit
        selectedImageView.backgroundColor = .black
        selectedImageView.clipsToBounds = true
        selectedImageView.isHidden = true

        closeButton.setImage(UIImage.icMultiple, for: .normal)
        closeButton.tintColor = .systemWhite
        closeButton.contentHorizontalAlignment = .fill
        closeButton.contentVerticalAlignment = .fill

        rotationControlsView.isHidden = true

        topControlsStackView.axis = .horizontal
        topControlsStackView.alignment = .fill
        topControlsStackView.spacing = 12
        topControlsStackView.addArrangedSubview(rotationControlsView)
        topControlsStackView.addArrangedSubview(topControlsSpacerView)
        topControlsStackView.addArrangedSubview(closeButton)

        photoConfirmationContainerView.isHidden = true
        roiOverlayView.isHidden = true
    }

    func setupLayout() {
        var subviews: [UIView] = [
            previewView,
            selectedImageView,
            topControlsStackView,
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

        topControlsStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(32)
        }

        closeButton.snp.makeConstraints {
            $0.size.equalTo(32)
        }
        rotationControlsView.snp.makeConstraints {
            $0.width.equalTo(76)
            $0.height.equalTo(32)
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
            self?.onEvent(.buttonClicked(.gallery))
            self?.presentPhotoLibrary()
        }
        bottomCameraShutterView.onCaptureTap = { [weak self] in
            self?.onEvent(.buttonClicked(.takeAPicture))
            self?.capturePhoto()
        }
        bottomCameraShutterView.onSwitchCameraTap = { [weak self] in
            self?.onEvent(.buttonClicked(.switchCamera))
            self?.sessionController.switchCamera()
        }
        photoConfirmationContainerView.onRetakeTap = { [weak self] in
            self?.onEvent(.buttonClicked(.retake))
            self?.resetCapturedPhoto()
        }
        photoConfirmationContainerView.onUploadTap = { [weak self] in
            self?.completeCapture()
        }
        rotationControlsView.onRotateLeftTap = { [weak self] in
            self?.onEvent(.buttonClicked(.rotateLeft))
            self?.rotateCapturedPhoto(clockwiseDegrees: -90)
        }
        rotationControlsView.onRotateRightTap = { [weak self] in
            self?.onEvent(.buttonClicked(.rotateRight))
            self?.rotateCapturedPhoto(clockwiseDegrees: 90)
        }
    }
}
