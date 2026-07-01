//
//  FirebaseServiceInterface.swift
//  FirebaseServiceInterface
//
//  Created by 김동준 on 7/1/26
//

public protocol FirebaseServiceInterface {
    func fetchAndActivate() async throws
    func getString(forKey key: String) -> String
    func getBool(forKey key: String) -> Bool
}
