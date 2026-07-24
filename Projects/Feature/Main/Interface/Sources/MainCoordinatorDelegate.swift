//
//  MainCoordinatorDelegate.swift
//  MainInterface
//
//  Created by 김동준 on 7/24/26.
//

@MainActor
public protocol MainCoordinatorDelegate: AnyObject {
    func didRequestLogout()
}
