//
//  SignUpDonePath.swift
//  SignUpDone
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture

@Reducer
public enum SignUpDonePath {
    case temp(TempFeature)
}

extension SignUpDonePath.State: Equatable {}
