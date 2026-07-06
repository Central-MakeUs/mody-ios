//
//  ModyGroupPath.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture

@Reducer
public enum ModyGroupPath {
    case temp(TempFeature)
}

extension ModyGroupPath.State: Equatable {}
