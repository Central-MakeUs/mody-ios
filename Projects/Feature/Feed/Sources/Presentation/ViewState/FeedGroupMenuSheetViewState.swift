//
//  FeedGroupMenuSheetViewState.swift
//  Feed
//
//  Created by 김동준 on 7/14/26.
//

import CommonDomain

struct FeedGroupMenuSheetViewState {
    let groupList: [GroupModel]
    let selectedGroup: GroupModel

    init?(state: FeedReactor.State) {
        guard !state.isFetchGroupLoading,
              let selectedGroup = state.selectedGroup else {
            return nil
        }

        self.groupList = state.groups
        self.selectedGroup = selectedGroup
    }
}
