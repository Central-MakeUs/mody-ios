//
//  AppAssembly+MyPage.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import MyPageInterface
import MyPage

extension AppAssembly {
    func assembleMyPageFeature(in container: Container) {
        container.register(MyPageBuildable.self) { _ in
            return MyPageBuilder()
        }
    }
}
