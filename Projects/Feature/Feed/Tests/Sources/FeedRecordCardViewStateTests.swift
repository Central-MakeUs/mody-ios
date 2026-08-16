//
//  FeedRecordCardViewStateTests.swift
//  FeedTests
//
//  Created by 김동준 on 7/29/26.
//

import XCTest
@testable import Feed

final class FeedRecordCardViewStateTests: XCTestCase {
    func testShowsReportMenuForAnotherMembersRecord() {
        let viewState = FeedRecordCardViewState(
            record: makeRecord(memberId: 2),
            myMemberId: 1
        )

        XCTAssertTrue(viewState.showsMoreButton)
        XCTAssertEqual(viewState.menus, [.report])
    }

    func testShowsDeleteMenuForMyRecord() {
        let viewState = FeedRecordCardViewState(
            record: makeRecord(memberId: 1),
            myMemberId: 1
        )

        XCTAssertTrue(viewState.showsMoreButton)
        XCTAssertEqual(viewState.menus, [.delete])
    }
}

private extension FeedRecordCardViewStateTests {
    func makeRecord(memberId: Int) -> FeedRecord {
        FeedRecord(
            recordId: 1,
            recordType: .meal,
            memberId: memberId,
            nickname: "테스터",
            profileImageUrl: nil,
            recordedTime: "12:00",
            menu: "메뉴",
            exerciseDurationMinutes: 0,
            exerciseName: "",
            imageUrl: "https://example.com/image.jpg",
            imageCropRegion: nil,
            recordingStreakDays: 1
        )
    }
}
