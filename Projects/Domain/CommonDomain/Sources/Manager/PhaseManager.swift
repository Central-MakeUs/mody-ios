//
//  PhaseManager.swift
//  CommonDomain
//
//  Created by 김동준 on 7/5/26
//

public final class PhaseManager {
    public static let shared = PhaseManager()

    public var isPhaseOne = false

    private init() {}
}
