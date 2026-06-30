//
//  MainCoordinatorDelegate.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

@MainActor
public protocol MainCoordinatorDelegate: AnyObject {
    func didRequestLogout(_ coordinator: MainCoordinator)
}
