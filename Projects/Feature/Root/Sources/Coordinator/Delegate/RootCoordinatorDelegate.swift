//
//  RootCoordinatorDelegate.swift
//  Root
//
//  Created by 김동준 on 6/25/26
//

@MainActor
public protocol RootCoordinatorDelegate: AnyObject {
    func didFinishAuthentication(_ coordinator: RootCoordinator)
}
