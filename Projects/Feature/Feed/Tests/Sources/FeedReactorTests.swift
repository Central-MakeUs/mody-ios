//
//  FeedReactorTests.swift
//  FeedTests
//
//  Created by 김동준 on 10/5/26.
//

import CoreAuthTesting
import FeedInterface
import XCTest
@testable import Feed

@MainActor
final class FeedReactorTests: XCTestCase {
    func testMarkingTodayWithRecordUpdatesCalendarOnlyOnce() {
        let reactor = makeReactor()
        let initial = reactor.initialState
        let today = initial.weekCalendarViewState.todayDate

        let state = reactor.reduce(state: initial, mutation: .markCalendarDateHasRecord(today))
        let markedAgain = reactor.reduce(state: state, mutation: .markCalendarDateHasRecord(today))

        XCTAssertEqual(state.weekCalendarViewState.calendarDates.filter(\.hasRecord).map(\.date), [today])
        XCTAssertEqual(markedAgain.weekCalendarViewState.calendarDates,
                       state.weekCalendarViewState.calendarDates)
        XCTAssertEqual(state.weekCalendarViewState.selectedDate, today)
    }

    func testResetFeedRecordsClearsPagination() {
        let reactor = makeReactor()
        let page = FeedRecordPage(records: [], nextCursor: 3, hasNext: true)
        let loaded = reactor.reduce(state: reactor.initialState, mutation: .setFeedPage(page))

        let reset = reactor.reduce(state: loaded, mutation: .resetFeedRecords)

        XCTAssertTrue(reset.feedRecords.isEmpty)
        XCTAssertNil(reset.nextFeedCursor)
        XCTAssertFalse(reset.hasNextFeedPage)
    }

    func testRecordMenuRequestsConfirmation() async {
        let report = expectation(description: "report confirmation")
        let delete = expectation(description: "delete confirmation")
        let reactor = makeReactor { output in
            switch output {
            case .reportConfirmationRequested(recordId: 12): report.fulfill()
            case .deleteConfirmationRequested(recordId: 12): delete.fulfill()
            default: XCTFail("Unexpected output: \(output)")
            }
        }

        let reportDisposable = reactor.mutate(action: .didTapRecordMenu(.report, recordId: 12))
            .subscribe()
        let deleteDisposable = reactor.mutate(action: .didTapRecordMenu(.delete, recordId: 12))
            .subscribe()
        await fulfillment(of: [report, delete], timeout: 2)
        reportDisposable.dispose()
        deleteDisposable.dispose()
    }

    func testRecordButtonCollapsesFabAndRoutesToRecord() async {
        let router = FeedRouterSpy()
        let routed = expectation(description: "record route")
        router.onRoute = { route in
            XCTAssertEqual(route, .routeToRecord(.meal))
            routed.fulfill()
        }
        let reactor = makeReactor(router: router)
        var mutations: [FeedReactor.Mutation] = []

        let disposable = reactor.mutate(action: .didTapRecordButton(.meal))
            .subscribe(onNext: { mutations.append($0) })
        await fulfillment(of: [routed], timeout: 2)

        XCTAssertEqual(mutations.count, 1)
        if case let .setFloatingActionButtonExpanded(isExpanded) = mutations[0] {
            XCTAssertFalse(isExpanded)
        } else {
            XCTFail("Expected FAB collapse")
        }
        XCTAssertEqual(router.routes, [.routeToRecord(.meal)])
        disposable.dispose()
    }

    private func makeReactor(
        router: FeedRouterSpy? = nil,
        output: @escaping @MainActor (FeedOutput) -> Void = { _ in }
    ) -> FeedReactor {
        FeedReactor(
            authUseCase: AuthUseCaseStub(),
            groupUseCase: FeedGroupUseCaseStub(),
            feedUseCase: FeedUseCase(feedRepository: FeedRepositorySpy()),
            router: router ?? FeedRouterSpy(),
            output: output
        )
    }
}
