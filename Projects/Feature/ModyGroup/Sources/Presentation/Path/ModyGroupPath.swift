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
    private let groupCreateFeature: GroupCreateFeature

    public init(
        groupInviteFeature: GroupInviteFeature,
        groupCreateFeature: GroupCreateFeature
    ) {
        self.groupInviteFeature = groupInviteFeature
        self.groupCreateFeature = groupCreateFeature
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
            groupCreateFeature
        }
        Scope(state: \.invite, action: \.invite) {
            groupInviteFeature
        }
    }
}
