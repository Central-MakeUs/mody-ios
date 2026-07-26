//
//  CameraContainerViewController+PHPickerViewControllerDelegate.swift
//  CoreCamera
//
//  Created by 김동준 on 7/23/26
//

import PhotosUI
import UniformTypeIdentifiers

/// 앨범 선택 결과를 앱 소유 임시 파일과 화면용 미리보기로 변환해 카메라 화면에 반영합니다.
extension CameraContainerViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        // 사용자가 선택하지 않고 닫았다면 중단된 카메라 세션을 다시 시작합니다.
        guard let result = results.first else {
            cancelPhotoLibraryLoad()
            sessionController.start()
            return
        }

        cancelPhotoLibraryLoad()
        let originalFileName = PhotoFileNameUtil.makePhotoLibraryFileName(from: result)
        let provider = result.itemProvider

        // JPEG 표현을 우선 사용하고, 없다면 provider가 제공하는 이미지 타입 중 하나를 사용합니다.
        guard let imageTypeIdentifier = provider.registeredTypeIdentifiers.first(where: {
            UTType($0) == .jpeg
        }) ?? provider.registeredTypeIdentifiers.first(where: {
            UTType($0)?.conforms(to: .image) == true
        }) else {
            sessionController.start()
            return
        }

        // 취소 이후에도 늦은 completion이 올 수 있으므로 요청별 ID로 현재 요청인지 판별합니다.
        let loadID = UUID()
        // 콜백은 main queue가 아닐 수 있어 ViewController와 분리된 processor를 값으로 캡처합니다.
        let capturedPhotoProcessor = capturedPhotoProcessor
        photoLibraryLoadID = loadID
        photoLibraryLoadProgress = provider.loadFileRepresentation(
            forTypeIdentifier: imageTypeIdentifier
        ) { [weak self, capturedPhotoProcessor] fileURL, _ in
            // PHPicker의 임시 URL은 이 콜백 뒤에 사라질 수 있어 main 전환 전에 동기 복사합니다.
            guard self != nil,
                  let fileURL,
                  let capturedPhoto = try? capturedPhotoProcessor.makeCapturedPhoto(
                    fileURL: fileURL,
                    fileName: originalFileName
                  ) else {
                DispatchQueue.main.async { [weak self] in
                    guard self?.photoLibraryLoadID == loadID else { return }
                    self?.cancelPhotoLibraryLoad()
                    self?.sessionController.start()
                }
                return
            }

            // 파일 처리와 다운샘플링을 끝낸 뒤 화면 상태만 main queue에서 변경합니다.
            DispatchQueue.main.async { [weak self, capturedPhotoProcessor] in
                guard let self else {
                    capturedPhotoProcessor.removeCapturedPhoto(capturedPhoto)
                    return
                }
                guard self.photoLibraryLoadID == loadID else {
                    // 취소되거나 교체된 요청의 결과 파일은 화면에 반영하지 않고 바로 제거합니다.
                    capturedPhotoProcessor.removeCapturedPhoto(capturedPhoto)
                    return
                }
                self.cancelPhotoLibraryLoad()
                self.setCapturedPhoto(capturedPhoto)
            }
        }
    }
}
