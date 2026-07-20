//
//  AppAssembly+CoreCamera.swift
//  Mody
//
//  Created by 김동준 on 7/20/26.
//

import CoreCamera
import CoreCameraInterface
import Swinject

extension AppAssembly {
    func assembleCoreCamera(in container: Container) {
        container.register(CameraPermissionInterface.self) { _ in
            CameraPermissionService()
        }
    }
}
