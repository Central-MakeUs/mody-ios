//  UtilFormattingTests.swift
//  UtilTests
//
//  Created by 김동준 on 10/8/26.
//

import Foundation
import XCTest
import Util

final class UtilFormattingTests: XCTestCase {
    func testDateFormattingAndParsingUseKoreanTimeZone() throws {
        let calendar = Date.koreanCalendar
        let date = try XCTUnwrap(calendar.date(
            from: DateComponents(year: 2026, month: 10, day: 8, hour: 13, minute: 5)
        ))

        XCTAssertEqual(date.toString(), "2026-10-08")
        XCTAssertEqual(date.toString(format: .mmdd), "10-08")
        XCTAssertEqual(date.toString(format: .custom("yyyy/MM/dd HH:mm")), "2026/10/08 13:05")
        XCTAssertEqual("2026-10-08".toDate(), calendar.startOfDay(for: date))
        XCTAssertNil("2026-02-30".toDate())

        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let utcPreviousDay = try XCTUnwrap(utcCalendar.date(
            from: DateComponents(year: 2026, month: 10, day: 7, hour: 15, minute: 5)
        ))
        XCTAssertEqual(utcPreviousDay.toString(), "2026-10-08")
    }

    func testFixedTimeAndHourMinuteParsing() throws {
        let calendar = Date.koreanCalendar
        let date = try XCTUnwrap("09:05".toHourMinDate())
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        XCTAssertEqual(components.year, 2000)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 1)
        XCTAssertEqual(components.hour, 9)
        XCTAssertEqual(components.minute, 5)
        XCTAssertEqual(String.toHourMinString(hour: 9, minute: 5), "09:05")
    }

    func testHourMinuteParsingRejectsInvalidValues() {
        for input in ["", "09", "24:00", "12:60", "noon:00"] {
            XCTAssertNil(input.toHourMinDate(), input)
        }
    }

    func testDayAndStartOfDayUseKoreanCalendar() throws {
        let calendar = Date.koreanCalendar
        let date = try XCTUnwrap(calendar.date(
            from: DateComponents(year: 2026, month: 10, day: 8, hour: 13, minute: 5)
        ))
        let start = try XCTUnwrap(calendar.date(
            from: DateComponents(year: 2026, month: 10, day: 8)
        ))

        XCTAssertEqual(date.day(), 8)
        XCTAssertEqual(date.startOfDay(), start)
    }

    func testKoreanTimeStringsAtMidnightAndNoon() throws {
        let calendar = Date.koreanCalendar
        let midnight = try XCTUnwrap("00:04".toHourMinDate())
        let noon = try XCTUnwrap("12:05".toHourMinDate())
        let afternoon = try XCTUnwrap("13:06".toHourMinDate())

        XCTAssertEqual(midnight.toHourMinTimeString(calendar: calendar), "00:04")
        XCTAssertEqual(midnight.toKoreanTimeString(calendar: calendar), "오전 12:04")
        XCTAssertEqual(noon.toKoreanTimeString(calendar: calendar), "오후 12:05")
        XCTAssertEqual(afternoon.toKoreanTimeString(calendar: calendar), "오후 1:06")
    }

    func testNeighboringTimeValuesWrapAround() throws {
        let midnight = try XCTUnwrap("00:00".toHourMinDate())

        XCTAssertEqual(midnight.neighboringHours(), [22, 23, 0, 1, 2])
        XCTAssertEqual(midnight.neighboringMinutes(), [58, 59, 0, 1, 2])
    }

    func testRelativeTimeBoundaryValuesAndFutureDate() {
        let reference = Date(timeIntervalSince1970: 1_000_000)
        let cases: [(TimeInterval, String)] = [
            (0, "방금 전"),
            (59, "방금 전"),
            (60, "1분 전"),
            (3_599, "59분 전"),
            (3_600, "1시간 전"),
            (86_399, "23시간 전"),
            (86_400, "1일 전"),
            (-60, "방금 전")
        ]

        for (elapsed, expected) in cases {
            let date = reference.addingTimeInterval(-elapsed)
            XCTAssertEqual(date.relativeTimeString(to: reference), expected, "elapsed: \(elapsed)")
        }
    }
}
