//
//  CameraContainerViewController+PHPickerViewControllerDelegate.swift
//  CoreCamera
//
//  Created by 김동준 on 7/23/26
//

import PhotosUI

extension CameraContainerViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else {
            sessionController.start()
            return
        }

        let originalFileName = PhotoFileNameUtil.makePhotoLibraryFileName(from: result)
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
