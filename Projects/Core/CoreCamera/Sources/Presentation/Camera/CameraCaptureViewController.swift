//
//  CameraCaptureViewController.swift
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

final class CameraCaptureViewController: UIViewController {
    private struct CapturedPhoto {
        let image: UIImage
        let originalFileName: String
    }

    private let initialSource: CameraCaptureSource
    private let onComplete: (CameraCaptureResult) -> Void
    private let onCancel: () -> Void
    private let sessionController = CameraCaptureSessionController()

    private let previewView = CameraPreviewView()
    private let selectedImageView = UIImageView()
    private let closeButton = UIButton(type: .system)
    private let shutterControlsView = CameraShutterControlsView()
    private let photoConfirmationControlsView = CameraPhotoConfirmationControlsView()
    private let selectionOverlayView = CameraSelectionOverlayView()

    private var capturedPhoto: CapturedPhoto?
    private var didPresentInitialPhotoLibrary = false

    init(
        initialSource: CameraCaptureSource,
        onComplete: @escaping (CameraCaptureResult) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initialSource = initialSource
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
        sessionController.stop()
    }
}

private extension CameraCaptureViewController {
    func setupUI() {
        view.backgroundColor = .systemBlack

        selectedImageView.contentMode = .scaleAspectFill
        selectedImageView.clipsToBounds = true
        selectedImageView.isHidden = true

        closeButton.setImage(UIImage.icMultiple, for: .normal)
        closeButton.tintColor = .gray10
        closeButton.contentHorizontalAlignment = .fill
        closeButton.contentVerticalAlignment = .fill

        photoConfirmationControlsView.isHidden = true
        selectionOverlayView.isHidden = true
    }

    func setupLayout() {
        [
            previewView,
            selectedImageView,
            selectionOverlayView,
            closeButton,
            shutterControlsView,
            photoConfirmationControlsView
        ].forEach {
            view.addSubview($0)
        }

        previewView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        selectedImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        selectionOverlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.trailing.equalToSuperview().inset(24)
            $0.size.equalTo(32)
        }

        shutterControlsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
            $0.height.equalTo(80)
        }

        photoConfirmationControlsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
            $0.height.equalTo(40)
        }
    }

    func bindActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        shutterControlsView.onGalleryTap = { [weak self] in
            self?.presentPhotoLibrary()
        }
        shutterControlsView.onCaptureTap = { [weak self] in
            self?.capturePhoto()
        }
        shutterControlsView.onSwitchCameraTap = { [weak self] in
            self?.sessionController.switchCamera()
        }
        photoConfirmationControlsView.onRetakeTap = { [weak self] in
            self?.resetCapturedPhoto()
        }
        photoConfirmationControlsView.onUploadTap = { [weak self] in
            self?.completeCapture()
        }
    }
}

private extension CameraCaptureViewController {
    func capturePhoto() {
        sessionController.capture { [weak self] image in
            guard let image else { return }
            self?.setCapturedPhoto(
                image,
                originalFileName: Self.makeCameraFileName()
            )
        }
    }

    func presentPhotoLibrary() {
        guard presentedViewController == nil else { return }

        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    func setCapturedPhoto(
        _ image: UIImage,
        originalFileName: String
    ) {
        capturedPhoto = CapturedPhoto(
            image: image,
            originalFileName: originalFileName
        )
        selectedImageView.image = image
        selectedImageView.isHidden = false
        shutterControlsView.isHidden = true
        photoConfirmationControlsView.isHidden = false
        selectionOverlayView.isHidden = false
        closeButton.tintColor = .systemWhite
        sessionController.stop()
    }

    func resetCapturedPhoto() {
        capturedPhoto = nil
        selectedImageView.image = nil
        selectedImageView.isHidden = true
        shutterControlsView.isHidden = false
        photoConfirmationControlsView.isHidden = true
        selectionOverlayView.isHidden = true
        closeButton.tintColor = .gray10
        sessionController.start()
    }

    func completeCapture() {
        guard let capturedPhoto else { return }

        let selectionFrame = selectionOverlayView.selectionFrame
        let selectionContainerSize = selectionOverlayView.bounds.size
        let cropOutput = CameraImageCropper().crop(
            image: capturedPhoto.image,
            selectionFrame: selectionFrame,
            containerSize: selectionContainerSize
        )
        guard let cropOutput else { return }

        printSelectionCoordinates(
            selectionFrame: selectionFrame,
            cropOutput: cropOutput
        )

        onComplete(
            CameraCaptureResult(
                image: capturedPhoto.image,
                croppedImage: cropOutput.croppedImage,
                normalizedSelectionFrame: cropOutput.normalizedSelectionFrame,
                originalFileName: capturedPhoto.originalFileName
            )
        )
    }

    func printSelectionCoordinates(
        selectionFrame: CGRect,
        cropOutput: CameraImageCropOutput
    ) {
        print(
            """
            [CoreCamera][Upload]
            관심 영역 좌표 (화면, 좌상단 원점): \(selectionFrame)
            원본 사진 좌표 (좌상단 원점): \(cropOutput.originalImageBounds)
            관심 영역 좌표 (원본 사진 기준, 좌상단 원점): \(cropOutput.selectionFrameInOriginalImage)
            관심 영역 정규화 좌표 (원본 사진 기준, 0...1): \(cropOutput.normalizedSelectionFrame)
            """
        )
    }

    @objc func closeTapped() {
        onCancel()
    }

    static func makeCameraFileName() -> String {
        makeGeneratedFileName(prefix: "MODY_PHOTO")
    }

    static func makeGeneratedFileName(prefix: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd_HHmmss"

        let timestamp = formatter.string(from: Date())
        let suffix = UUID().uuidString.prefix(6).uppercased()
        return "\(prefix)_\(timestamp)_\(suffix).jpg"
    }

    func makePhotoLibraryFileName(from result: PHPickerResult) -> String {
        if let originalFileName = fetchOriginalFileName(from: result) {
            return originalFileName
        }

        return Self.makeGeneratedFileName(prefix: "MODY_PHOTO_LIBRARY")
    }

    func fetchOriginalFileName(from result: PHPickerResult) -> String? {
        guard let assetIdentifier = result.assetIdentifier else { return nil }

        let fetchResult = PHAsset.fetchAssets(
            withLocalIdentifiers: [assetIdentifier],
            options: nil
        )
        guard let asset = fetchResult.firstObject else { return nil }

        let resources = PHAssetResource.assetResources(for: asset)
        return resources.first {
            $0.type == .photo || $0.type == .fullSizePhoto
        }?.originalFilename ?? resources.first?.originalFilename
    }
}

extension CameraCaptureViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else {
            sessionController.start()
            return
        }

        let originalFileName = makePhotoLibraryFileName(from: result)
        let provider = result.itemProvider

        guard provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.setCapturedPhoto(
                    image,
                    originalFileName: originalFileName
                )
            }
        }
    }
}
