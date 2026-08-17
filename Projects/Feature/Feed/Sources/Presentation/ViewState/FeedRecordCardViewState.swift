//
//  FeedRecordCardViewState.swift
//  Feed
//
//  Created by 김동준 on 7/21/26
//

struct FeedRecordCardViewState: Equatable {
    let recordId: Int
    let nickname: String
    let profileImageUrl: String?
    let streakText: String
    let isStreakChipHidden: Bool
    let isMine: Bool
    let showsMoreButton: Bool
    let menus: [FeedRecordMenu]
    let imageUrl: String
    let imageCropRegion: FeedImageCropRegion?
    let firstInfoTitle: String
    let firstInfoValue: String
    let secondInfoTitle: String
    let secondInfoValue: String

    init(
        record: FeedRecord,
        myMemberId: Int?
    ) {
        let isMine = record.memberId == myMemberId

        recordId = record.recordId
        nickname = record.nickname
        profileImageUrl = record.profileImageUrl
        streakText = "\(record.recordingStreakDays)일차"
        isStreakChipHidden = record.recordingStreakDays <= 0
        self.isMine = isMine
        showsMoreButton = true
        menus = isMine ? [.delete] : [.report]
        imageUrl = record.imageUrl
        imageCropRegion = record.imageCropRegion

        switch record.recordType {
        case .meal:
            firstInfoTitle = "식사 시간"
            firstInfoValue = record.recordedTime
            secondInfoTitle = "메뉴"
            secondInfoValue = record.menu
        case .exercise:
            firstInfoTitle = "운동 시간"
            firstInfoValue = "\(record.exerciseDurationMinutes)분"
            secondInfoTitle = "운동종류"
            secondInfoValue = record.exerciseName
        }
    }
}

struct FeedListViewState: Equatable {
    let records: [FeedRecordCardViewState]
    let isInitialLoading: Bool
    let hasNextPage: Bool
    let isEmpty: Bool
}
