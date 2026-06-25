//
//  AppAssembly.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Swinject

struct AppAssembly: Assembly {
    func assemble(container: Container) {
        assembleRoot(in: container)
        assembleApp(in: container)
    }
}
