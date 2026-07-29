//
//  FeedReactorPaginationTests.swift
//  FeedTests
//
//  Created by 김동준 on 7/25/26.
//

import CommonDomain
import CoreAuthInterface
import FeedInterface
import ModyGroupInterface
import RxSwift
import XCTest
@testable import Feed

@MainActor
final class FeedReactorPaginationTests: XCTestCase {
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }

    func testBottomReachedAppendsNextPageAndFinishesLoading() async throws {
        let feedRepository = FeedPaginationRepositoryMock(
            pages: [
                makePage(recordIDs: [5, 4], nextCursor: 4, hasNext: true),
                makePage(recordIDs: [3, 2], nextCursor: nil, hasNext: false)
            ]
        )
        let reactor = makeReactor(feedRepository: feedRepository)

        let initialPageLoaded = expectation(description: "initial feed page loaded")
        reactor.state
            .filter {
                $0.feedRecords.map(\.recordId) == [5, 4]
                    && !$0.isInitialFeedLoading
            }
            .take(1)
            .subscribe(onNext: { _ in initialPageLoaded.fulfill() })
            .disposed(by: disposeBag)

        reactor.action.onNext(.viewDidLoad)
        await fulfillment(of: [initialPageLoaded], timeout: 1)

        let nextPageLoaded = expectation(description: "next feed page loaded")
        reactor.state
            .filter {
                $0.feedRecords.map(\.recordId) == [5, 4, 3, 2]
                    && !$0.isNextPageLoading
            }
            .take(1)
            .subscribe(onNext: { _ in nextPageLoaded.fulfill() })
            .disposed(by: disposeBag)

        reactor.action.onNext(.didReachFeedListBottom)
        await fulfillment(of: [nextPageLoaded], timeout: 1)

        let requests = await feedRepository.requests
        XCTAssertEqual(requests.map(\.cursor), [nil, 4])
        XCTAssertFalse(reactor.currentState.hasNextFeedPage)
    }

    func testRecordCreatedPrependsOnlyNewRecordsAndPreservesPaginationCursor() async throws {
        let feedRepository = FeedPaginationRepositoryMock(
            pages: [
                makePage(recordIDs: [5, 4], nextCursor: 4, hasNext: true),
                makePage(recordIDs: [6, 5], nextCursor: 5, hasNext: true)
            ]
        )
        let reactor = makeReactor(feedRepository: feedRepository)
        let todayDate = reactor.currentState.weekCalendarViewState.todayDate

        let initialPageLoaded = expectation(description: "initial feed page loaded")
        reactor.state
            .filter {
                $0.feedRecords.map(\.recordId) == [5, 4]
                    && !$0.isInitialFeedLoading
            }
            .take(1)
            .subscribe(onNext: { _ in initialPageLoaded.fulfill() })
            .disposed(by: disposeBag)

        reactor.action.onNext(.viewDidLoad)
        await fulfillment(of: [initialPageLoaded], timeout: 1)

        let latestRecordMerged = expectation(description: "latest feed record merged")
        reactor.state
            .filter { state in
                state.feedRecords.map(\.recordId) == [6, 5, 4]
                    && state.weekCalendarViewState.calendarDates
                        .first(where: { $0.date == todayDate })?
                        .hasRecord == true
            }
            .take(1)
            .subscribe(onNext: { _ in latestRecordMerged.fulfill() })
            .disposed(by: disposeBag)

        reactor.action.onNext(.input(.recordCreated))
        await fulfillment(of: [latestRecordMerged], timeout: 1)

        let requests = await feedRepository.requests
        XCTAssertEqual(requests.map(\.cursor), [nil, nil])
        let activityCalendarRequests = await feedRepository.activityCalendarRequests
        XCTAssertEqual(activityCalendarRequests.count, 1)
        XCTAssertEqual(reactor.currentState.nextFeedCursor, 4)
        XCTAssertTrue(reactor.currentState.hasNextFeedPage)
        XCTAssertFalse(reactor.currentState.isInitialFeedLoading)
    }
}

private extension FeedReactorPaginationTests {
    func makeReactor(feedRepository: FeedRepositoryProtocol) -> FeedReactor {
        FeedReactor(
            authUseCase: FeedPaginationAuthUseCaseMock(),
            groupUseCase: FeedPaginationGroupUseCaseMock(),
            feedUseCase: FeedUseCase(feedRepository: feedRepository),
            router: FeedPaginationRouterMock()
        )
    }

    func makePage(
        recordIDs: [Int],
        nextCursor: Int?,
        hasNext: Bool
    ) -> FeedRecordPage {
        FeedRecordPage(
            records: recordIDs.map(makeRecord),
            nextCursor: nextCursor,
            hasNext: hasNext
        )
    }

    func makeRecord(recordID: Int) -> FeedRecord {
        FeedRecord(
            recordId: recordID,
            recordType: .meal,
            memberId: 1,
            nickname: "테스터",
            profileImageUrl: nil,
            recordedTime: "12:00",
            menu: "메뉴",
            exerciseDurationMinutes: 0,
            exerciseName: "",
            imageUrl: "https://example.com/\(recordID).jpg",
            imageCropRegion: nil,
            recordingStreakDays: 1
        )
    }
}

private actor FeedPaginationRepositoryMock: FeedRepositoryProtocol {
    struct Request: Equatable {
        let groupId: Int
        let date: String
        let cursor: Int?
        let size: Int
    }

    private var pages: [FeedRecordPage]
    private(set) var requests: [Request] = []
    private(set) var activityCalendarRequests: [String] = []

    init(pages: [FeedRecordPage]) {
        self.pages = pages
    }

    func getRecords(
        groupId: Int,
        date: String,
        cursor: Int?,
        size: Int
    ) async throws -> FeedRecordPage {
        requests.append(
            Request(
                groupId: groupId,
                date: date,
                cursor: cursor,
                size: size
            )
        )
        return pages.removeFirst()
    }

    func getActivityCalendar(
        groupId: Int,
        baseDate: String
    ) async throws -> FeedActivityCalendarModel {
        activityCalendarRequests.append(baseDate)
        return FeedActivityCalendarModel(
            weekStartDate: baseDate,
            weekEndDate: baseDate,
            days: []
        )
    }

    func postRecord(_ request: FeedRecordCreateRequest) async throws {}

    func postRecordReport(groupId: Int, recordId: Int) async throws {}
}

private struct FeedPaginationAuthUseCaseMock: AuthUseCaseProtocol {
    func signIn(
        loginType: SocialLoginType,
        accessToken: String
    ) async throws -> AuthSession {
        throw CancellationError()
    }

    func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        UserInfo(
            memberId: 1,
            nickname: "테스터",
            profileImageUrl: nil,
            daysTogether: 1,
            personalInfoCompleted: true,
            groupOnboardingCompleted: true,
            mainAccessible: true
        )
    }

    func logout() async throws {}

    func deleteAccount() async throws {}
}

private struct FeedPaginationGroupUseCaseMock: GroupUseCaseProtocol {
    func createGroup(name: String) async throws -> String {
        "TEST"
    }

    func joinGroup(code: String) async throws {}

    func getGroups() async throws -> [GroupModel] {
        [
            GroupModel(
                groupId: 1,
                name: "테스트 그룹",
                code: "TEST",
                memberCount: 1
            )
        ]
    }

    func exitGroup(groupId: Int) async throws {}
}

@MainActor
private final class FeedPaginationRouterMock: FeedRouter {
    func route(from route: FeedRoute) {}
}
