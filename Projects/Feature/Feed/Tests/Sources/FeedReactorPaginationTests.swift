//
//  FeedReactorPaginationTests.swift
//  FeedTests
//
//  Created by 김동준 on 7/25/26.
//

import CommonDomain
import CoreAuthInterface
import CoreAnalyticsInterface
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
        let reactor = makeReactor(
            feedRepository: feedRepository,
            outputHandler: FeedOutputHandlerSpy()
        )

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
        let outputHandler = FeedOutputHandlerSpy()
        let reactor = makeReactor(
            feedRepository: feedRepository,
            outputHandler: outputHandler
        )
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
        let recordUpdated = expectation(description: "record update output sent")
        outputHandler.onOutput = { output in
            guard output == .recordUpdated else { return }
            recordUpdated.fulfill()
        }
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
        await fulfillment(of: [latestRecordMerged, recordUpdated], timeout: 1)

        let requests = await feedRepository.requests
        XCTAssertEqual(requests.map(\.cursor), [nil, nil])
        let activityCalendarRequests = await feedRepository.activityCalendarRequests
        XCTAssertEqual(activityCalendarRequests.count, 1)
        XCTAssertEqual(reactor.currentState.nextFeedCursor, 4)
        XCTAssertTrue(reactor.currentState.hasNextFeedPage)
        XCTAssertFalse(reactor.currentState.isInitialFeedLoading)
    }

    func testInitialLoadEmitsSelectedGroupOnce() async {
        let firstGroup = makeGroup(id: 1)
        let secondGroup = makeGroup(id: 2)
        let outputHandler = FeedOutputHandlerSpy()
        let reactor = makeReactor(
            feedRepository: FeedPaginationRepositoryMock(
                pages: [makePage(recordIDs: [1], nextCursor: nil, hasNext: false)]
            ),
            groupUseCase: FeedGroupUseCaseSequenceMock(
                responses: [[firstGroup, secondGroup]]
            ),
            outputHandler: outputHandler
        )

        await loadInitialContent(of: reactor)

        XCTAssertEqual(reactor.currentState.selectedGroup, firstGroup)
        XCTAssertEqual(
            selectedGroupOutputs(in: outputHandler.outputs),
            [.selectedGroupUpdated(firstGroup)]
        )
    }

    func testSelectingDifferentGroupEmitsSelectedGroupOnce() async {
        let firstGroup = makeGroup(id: 1)
        let secondGroup = makeGroup(id: 2)
        let outputHandler = FeedOutputHandlerSpy()
        let reactor = makeReactor(
            feedRepository: FeedPaginationRepositoryMock(
                pages: [
                    makePage(recordIDs: [1], nextCursor: nil, hasNext: false),
                    makePage(recordIDs: [2], nextCursor: nil, hasNext: false)
                ]
            ),
            groupUseCase: FeedGroupUseCaseSequenceMock(
                responses: [[firstGroup, secondGroup]]
            ),
            outputHandler: outputHandler
        )
        await loadInitialContent(of: reactor)

        let selectedGroupContentLoaded = expectation(
            description: "selected group content loaded"
        )
        reactor.state
            .filter {
                $0.selectedGroup == secondGroup
                    && $0.feedRecords.map(\.recordId) == [2]
                    && !$0.isInitialFeedLoading
            }
            .take(1)
            .subscribe(onNext: { _ in selectedGroupContentLoaded.fulfill() })
            .disposed(by: disposeBag)

        reactor.action.onNext(.didSelectGroup(secondGroup))
        await fulfillment(of: [selectedGroupContentLoaded], timeout: 1)

        XCTAssertEqual(
            selectedGroupOutputs(in: outputHandler.outputs),
            [
                .selectedGroupUpdated(firstGroup),
                .selectedGroupUpdated(secondGroup)
            ]
        )
    }

    func testRefreshGroupsAfterExternalDeletionUpdatesSelectedGroupOnce() async {
        let firstGroup = makeGroup(id: 1)
        let secondGroup = makeGroup(id: 2)
        let outputHandler = FeedOutputHandlerSpy()
        let reactor = makeReactor(
            feedRepository: FeedPaginationRepositoryMock(
                pages: [
                    makePage(recordIDs: [1], nextCursor: nil, hasNext: false),
                    makePage(recordIDs: [2], nextCursor: nil, hasNext: false)
                ]
            ),
            groupUseCase: FeedGroupUseCaseSequenceMock(
                responses: [
                    [firstGroup, secondGroup],
                    [secondGroup],
                    []
                ]
            ),
            outputHandler: outputHandler
        )
        await loadInitialContent(of: reactor)

        let fallbackGroupContentLoaded = expectation(
            description: "fallback group content loaded"
        )
        reactor.state
            .filter {
                $0.selectedGroup == secondGroup
                    && $0.feedRecords.map(\.recordId) == [2]
                    && !$0.isFetchGroupLoading
                    && !$0.isInitialFeedLoading
            }
            .take(1)
            .subscribe(onNext: { _ in fallbackGroupContentLoaded.fulfill() })
            .disposed(by: disposeBag)

        reactor.action.onNext(.input(.refreshGroups))
        await fulfillment(of: [fallbackGroupContentLoaded], timeout: 1)

        let emptyGroupStateLoaded = expectation(description: "empty group state loaded")
        reactor.state
            .filter {
                $0.groups.isEmpty
                    && $0.selectedGroup == nil
                    && $0.feedRecords.isEmpty
                    && !$0.isFetchGroupLoading
            }
            .take(1)
            .subscribe(onNext: { _ in emptyGroupStateLoaded.fulfill() })
            .disposed(by: disposeBag)

        reactor.action.onNext(.input(.refreshGroups))
        await fulfillment(of: [emptyGroupStateLoaded], timeout: 1)

        XCTAssertEqual(
            selectedGroupOutputs(in: outputHandler.outputs),
            [
                .selectedGroupUpdated(firstGroup),
                .selectedGroupUpdated(secondGroup),
                .selectedGroupUpdated(nil)
            ]
        )
    }

    func testReportMenuTapRequestsConfirmationWithoutCallingAPI() async {
        let feedRepository = FeedPaginationRepositoryMock(pages: [])
        let outputHandler = FeedOutputHandlerSpy()
        let reactor = makeReactor(
            feedRepository: feedRepository,
            outputHandler: outputHandler
        )
        let confirmationRequested = expectation(description: "report confirmation requested")
        outputHandler.onOutput = { output in
            guard output == .reportConfirmationRequested(recordId: 22) else { return }
            confirmationRequested.fulfill()
        }

        reactor.action.onNext(.didTapRecordMenu(.report, recordId: 22))

        await fulfillment(of: [confirmationRequested], timeout: 1)
        XCTAssertEqual(
            outputHandler.outputs,
            [.reportConfirmationRequested(recordId: 22)]
        )
        let reportRequests = await feedRepository.reportRequests
        XCTAssertTrue(reportRequests.isEmpty)
    }

    func testReportConfirmedCallsAPIAndEmitsSuccess() async {
        let feedRepository = FeedPaginationRepositoryMock(
            pages: [makePage(recordIDs: [], nextCursor: nil, hasNext: false)]
        )
        let outputHandler = FeedOutputHandlerSpy()
        let reactor = makeReactor(
            feedRepository: feedRepository,
            outputHandler: outputHandler
        )
        await loadInitialContent(of: reactor)

        let reportSucceeded = expectation(description: "report succeeded")
        outputHandler.onOutput = { output in
            guard output == .reportSucceeded else { return }
            reportSucceeded.fulfill()
        }

        reactor.action.onNext(.input(.reportConfirmed(recordId: 22)))

        await fulfillment(of: [reportSucceeded], timeout: 1)
        XCTAssertEqual(outputHandler.outputs.last, .reportSucceeded)
        let reportRequests = await feedRepository.reportRequests
        XCTAssertEqual(reportRequests, [.init(groupId: 1, recordId: 22)])
    }

    func testReportFailureEmitsNormalizedCommonError() async {
        let feedRepository = FeedPaginationRepositoryMock(
            pages: [makePage(recordIDs: [], nextCursor: nil, hasNext: false)],
            reportShouldFail: true
        )
        let outputHandler = FeedOutputHandlerSpy()
        let reactor = makeReactor(
            feedRepository: feedRepository,
            outputHandler: outputHandler
        )
        await loadInitialContent(of: reactor)

        let reportFailed = expectation(description: "report failed")
        outputHandler.onOutput = { output in
            guard output == .reportFailed(.unknown) else { return }
            reportFailed.fulfill()
        }

        reactor.action.onNext(.input(.reportConfirmed(recordId: 22)))

        await fulfillment(of: [reportFailed], timeout: 1)
        XCTAssertEqual(outputHandler.outputs.last, .reportFailed(.unknown))
    }

    func testNudgeButtonTapRoutesToChallenge() async {
        let router = FeedPaginationRouterMock()
        let reactor = makeReactor(
            feedRepository: FeedPaginationRepositoryMock(pages: []),
            outputHandler: FeedOutputHandlerSpy(),
            router: router
        )
        let challengeRouted = expectation(description: "challenge routed")
        router.onRoute = { route in
            guard route == .routeToChallenge else { return }
            challengeRouted.fulfill()
        }

        reactor.action.onNext(.didTapNudgeButton)

        await fulfillment(of: [challengeRouted], timeout: 1)
        XCTAssertEqual(router.routes, [.routeToChallenge])
    }
}

private extension FeedReactorPaginationTests {
    func makeReactor(
        feedRepository: FeedRepositoryProtocol,
        groupUseCase: GroupUseCaseProtocol = FeedPaginationGroupUseCaseMock(),
        outputHandler: FeedOutputHandler,
        router: FeedRouter? = nil
    ) -> FeedReactor {
        FeedReactor(
            authUseCase: FeedPaginationAuthUseCaseMock(),
            groupUseCase: groupUseCase,
            feedUseCase: FeedUseCase(feedRepository: feedRepository),
            analyticsUseCase: FeedAnalyticsUseCaseMock(),
            router: router ?? FeedPaginationRouterMock(),
            output: { [weak outputHandler] output in
                outputHandler?.handle(output: output)
            }
        )
    }

    func loadInitialContent(of reactor: FeedReactor) async {
        let initialContentLoaded = expectation(description: "initial content loaded")
        reactor.state
            .filter {
                $0.selectedGroup != nil
                    && !$0.isFetchGroupLoading
                    && !$0.isInitialFeedLoading
            }
            .take(1)
            .subscribe(onNext: { _ in initialContentLoaded.fulfill() })
            .disposed(by: disposeBag)

        reactor.action.onNext(.viewDidLoad)
        await fulfillment(of: [initialContentLoaded], timeout: 1)
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

    func makeGroup(id: Int) -> GroupModel {
        GroupModel(
            groupId: id,
            name: "테스트 그룹 \(id)",
            code: "TEST\(id)",
            memberCount: 1
        )
    }

    func selectedGroupOutputs(in outputs: [FeedOutput]) -> [FeedOutput] {
        outputs.filter { output in
            if case .selectedGroupUpdated = output {
                return true
            }

            return false
        }
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

private struct FeedAnalyticsUseCaseMock: AnalyticsUseCaseProtocol {
    func setUserID(_ userID: String) {}
    func setUserNickname(_ nickname: String) {}
    func reset() {}
    func log(_ event: AmplitudeLogEvent) {}
    func viewDidLoad(screenName: String) {}
}

private actor FeedPaginationRepositoryMock: FeedRepositoryProtocol {
    struct Request: Equatable {
        let groupId: Int
        let date: String
        let cursor: Int?
        let size: Int
    }

    struct ReportRequest: Equatable {
        let groupId: Int
        let recordId: Int
    }

    private var pages: [FeedRecordPage]
    private let reportShouldFail: Bool
    private(set) var requests: [Request] = []
    private(set) var activityCalendarRequests: [String] = []
    private(set) var reportRequests: [ReportRequest] = []

    init(
        pages: [FeedRecordPage],
        reportShouldFail: Bool = false
    ) {
        self.pages = pages
        self.reportShouldFail = reportShouldFail
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

    func postRecordReport(groupId: Int, recordId: Int) async throws {
        reportRequests.append(.init(groupId: groupId, recordId: recordId))
        if reportShouldFail {
            throw FeedReportTestError.failed
        }
    }

    func deleteRecord(recordId: Int) async throws {}
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

private actor FeedGroupUseCaseSequenceMock: GroupUseCaseProtocol {
    private var responses: [[GroupModel]]

    init(responses: [[GroupModel]]) {
        self.responses = responses
    }

    func createGroup(name: String) async throws -> String {
        "TEST"
    }

    func joinGroup(code: String) async throws {}

    func getGroups() async throws -> [GroupModel] {
        guard !responses.isEmpty else { return [] }
        return responses.removeFirst()
    }

    func exitGroup(groupId: Int) async throws {}
}

@MainActor
private final class FeedPaginationRouterMock: FeedRouter {
    private(set) var routes: [FeedRoute] = []
    var onRoute: ((FeedRoute) -> Void)?

    func route(from route: FeedRoute) {
        routes.append(route)
        onRoute?(route)
    }
}

@MainActor
private final class FeedOutputHandlerSpy: FeedOutputHandler {
    private(set) var outputs: [FeedOutput] = []
    var onOutput: ((FeedOutput) -> Void)?

    func handle(output: FeedOutput) {
        outputs.append(output)
        onOutput?(output)
    }
}

private enum FeedReportTestError: Error {
    case failed
}
