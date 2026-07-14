//
//  MainGroupSelectSheetView.swift
//  Main
//
//  Created by 김동준 on 7/6/26.
//

import SwiftUI
import CommonDomain
import DesignSystem

struct MainGroupSelectSheetView: View {
    private let groupList: [GroupModel]
    private let selectedGroup: GroupModel
    private let onGroupSelect: (GroupModel) -> Void
    private let onAddGroupTap: () -> Void

    init(
        groupList: [GroupModel],
        selectedGroup: GroupModel,
        onGroupSelect: @escaping (GroupModel) -> Void,
        onAddGroupTap: @escaping () -> Void
    ) {
        self.groupList = groupList
        self.selectedGroup = selectedGroup
        self.onGroupSelect = onGroupSelect
        self.onAddGroupTap = onAddGroupTap
    }

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(groupList, id: \.groupId) { group in
                        groupRow(group)
                    }
                }
            }
            .scrollIndicators(.hidden)

            addGroupButton
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .padding(.top, 38)
        .frame(height: 407)
        .background(Color.systemWhite)
    }
}

private extension MainGroupSelectSheetView {
    func groupRow(_ group: GroupModel) -> some View {
        let isSelected = group.groupId == selectedGroup.groupId
        
        return Button {
            onGroupSelect(group)
        } label: {
            HStack(spacing: 0) {
                groupInfo(group)
                Spacer()
                
                if isSelected {
                    MText(
                        "현재 보는 중",
                        style: .c2,
                        color: .gray10
                    )
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.main)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.main4 : Color.gray1)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.main, lineWidth: 2)
                }
            }
        }
    }
    
    func groupInfo(_ group: GroupModel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            groupTitle(group)
            
            MText(
                "그룹코드 \(group.code)",
                style: .c2,
                color: .gray6,
                alignment: .leading
            )
        }
    }
    
    func groupTitle(_ group: GroupModel) -> some View {
        HStack(spacing: 4) {
            MText(
                group.name,
                style: .b3,
                color: .gray10,
                alignment: .leading
            )
            
            MText(
                "그룹",
                style: .c2,
                color: .gray5
            )
        }
    }
}

private extension MainGroupSelectSheetView {
    var addGroupButton: some View {
        MButton(
            "그룹 추가하기",
            style: .gray,
            horizontalPadding: 0,
            verticalPadding: 13,
            maxWidth: .infinity,
            trailingIcon: Image.icPlus,
            trailingIconSize: .init(width: 18, height: 18),
            trailingIconColor: .gray5,
            action: onAddGroupTap
        )
    }
}
