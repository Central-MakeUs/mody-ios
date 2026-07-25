//
//  AppAssembly+CoreCamera.swift
//  Mody
//
//  Created by 김동준 on 7/20/26.
//

import CoreCamera
import CoreCameraInterface
import CoreNetworkInterface
import Swinject

extension AppAssembly {
    func assembleCoreCamera(in container: Container) {
        container.register(ImageUploadRepositoryProtocol.self) { resolver in
            let network: CoreNetworkProtocol = resolver.resolve()

            return ImageUploadRepository(network: network)
        }
        container.register(ImageUploadUseCaseProtocol.self) { resolver in
            let repository: ImageUploadRepositoryProtocol = resolver.resolve()

            return ImageUploadUseCase(repository: repository)
        }
        container.register(CameraPermissionInterface.self) { _ in
            CameraPermissionService()
        }
        container.register(CameraCaptureBuildable.self) { _ in
            CameraCaptureBuilder()
        }
    }
}
