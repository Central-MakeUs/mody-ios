//
//  AppAssembly+CoreModyImage.swift
//  Mody
//
//  Created by 김동준 on 7/25/26.
//

import CoreModyImage
import CoreModyImageInterface
import CoreNetworkInterface
import Swinject

extension AppAssembly {
    func assembleCoreModyImage(in container: Container) {
        container.register(TemporaryImageFileRepositoryProtocol.self) { _ in
            TemporaryImageFileRepository()
        }
        container.register(TemporaryImageFileUseCaseProtocol.self) { resolver in
            let repository: TemporaryImageFileRepositoryProtocol = resolver.resolve()

            return TemporaryImageFileUseCase(repository: repository)
        }
        container.register(ImageUploadRepositoryProtocol.self) { resolver in
            let network: CoreNetworkProtocol = resolver.resolve()

            return ImageUploadRepository(network: network)
        }
        container.register(ImageUploadUseCaseProtocol.self) { resolver in
            let repository: ImageUploadRepositoryProtocol = resolver.resolve()

            return ImageUploadUseCase(repository: repository)
        }
        container.register(RemoteImageLoading.self) { _ in
            NukeRemoteImageLoader.shared
        }
    }
}
