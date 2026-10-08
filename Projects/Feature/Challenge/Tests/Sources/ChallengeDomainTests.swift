//  ChallengeDomainTests.swift
//  ChallengeTests
//
//  Created by 김동준 on 10/6/26.
//

import Foundation
import XCTest
@testable import Challenge

final class ChallengeDomainTests: XCTestCase {
    func testWalkChallengeRequiredGroupMapsAllServerValues() {
        XCTAssertEqual(WalkChallengeRequiredGroup(rawValue: "서울-인천"), .seoulIncheon)
        XCTAssertEqual(WalkChallengeRequiredGroup(rawValue: "서울-천안"), .seoulCheonan)
        XCTAssertEqual(WalkChallengeRequiredGroup(rawValue: "서울-대전"), .seoulDaejeon)
        XCTAssertEqual(WalkChallengeRequiredGroup(rawValue: "서울-대구"), .seoulDaegu)
        XCTAssertEqual(WalkChallengeRequiredGroup(rawValue: "서울-부산"), .seoulBusan)
        XCTAssertEqual(WalkChallengeRequiredGroup(rawValue: "서울-제주"), .seoulJeju)
    }

    func testRegionTypeMapsAllServerValues() {
        XCTAssertEqual(RegionType(rawValue: "서울"), .seoul)
        XCTAssertEqual(RegionType(rawValue: "인천"), .incheon)
        XCTAssertEqual(RegionType(rawValue: "천안"), .cheonan)
        XCTAssertEqual(RegionType(rawValue: "대전"), .daejeon)
        XCTAssertEqual(RegionType(rawValue: "대구"), .daegu)
        XCTAssertEqual(RegionType(rawValue: "부산"), .busan)
        XCTAssertEqual(RegionType(rawValue: "제주"), .jeju)
    }
}
