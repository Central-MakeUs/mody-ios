//
//  CoreHealthError.swift
//  CoreHealthInterface
//
//  Created by 김동준 on 8/4/26.
//

public enum CoreHealthError: Error, Equatable {
    case invalidDateRange
    case healthDataUnavailable
    case stepCountQueryFailed
}
