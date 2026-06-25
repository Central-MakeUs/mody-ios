//
//  Resolver+.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Swinject

extension Resolver {
    func resolve<T>() -> T {
        guard let instance = resolve(T.self) else {
            fatalError("DI Error: cannot resolve \(String(describing: T.self))")
        }
        return instance
    }

    func resolve<T, Argument>(argument: Argument) -> T {
        guard let instance = resolve(T.self, argument: argument) else {
            fatalError("DI Error: cannot resolve \(String(describing: T.self)) with argument \(String(describing: Argument.self))")
        }
        return instance
    }
}
