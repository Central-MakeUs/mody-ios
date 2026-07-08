//
//  AppAssembly+CoreKakao.swift
//  Mody
//
//  Created by 김동준 on 7/7/26
//

import CoreKakao
import CoreKakaoInterface
import Swinject

extension AppAssembly {
    func assembleCoreKakao(in container: Container) {
        container.register(CoreKakaoAuthInterface.self) { _ in
            CoreKakaoAuthService()
        }

        container.register(CoreKakaoShareInterface.self) { _ in
            CoreKakaoShareService()
        }
    }
}
