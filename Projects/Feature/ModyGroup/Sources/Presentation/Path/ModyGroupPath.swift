//
//  ModyGroupPath.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture

@Reducer
public struct ModyGroupPath {
    private let groupInviteFeature: GroupInviteFeature

    public init(groupInviteFeature: GroupInviteFeature) {
        self.groupInviteFeature = groupInviteFeature
    }

    @ObservableState
    public enum State: Equatable {
        case create(GroupCreateFeature.State)
        case invite(GroupInviteFeature.State)
    }

    public enum Action {
        case create(GroupCreateFeature.Action)
        case invite(GroupInviteFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.create, action: \.create) {
            GroupCreateFeature()
        }
        Scope(state: \.invite, action: \.invite) {
            groupInviteFeature
        }
    }
}
