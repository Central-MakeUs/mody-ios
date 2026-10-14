//  FeedDemoNetworkData.swift
//  FeedDemo
//
//  Created by 김동준 on 10/9/26.
//

import CommonDomain
import CoreNetworkInterface
import CoreNetworkTesting
import FeedTesting
import Foundation

actor FeedDemoNetworkData {
    private let scenario: FeedDemoScenario
    private var records: [[String: Any]]
    private var nextRecordID = 801

    init(scenario: FeedDemoScenario) {
        self.scenario = scenario
        records = (0..<8).map { index in
            let isOwn = index.isMultiple(of: 2)
            return [
                "recordId": 800 - index, "recordType": isOwn ? "MEAL" : "EXERCISE",
                "memberId": isOwn ? 100 : 200, "nickname": isOwn ? "내 기록" : "다른 멤버",
                "recordedTime": "12:00", "menu": isOwn ? "점심 식사" : "",
                "exerciseDurationMinutes": isOwn ? 0 : 40, "exerciseName": isOwn ? "" : "걷기",
                "imageUrl": "https://feed.demo/\(isOwn ? "meal" : "exercise")/\(800 - index)",
                "recordingStreakDays": index + 1
            ]
        }
    }

    func response(to endpoint: CoreNetworkEndpoint) throws -> Data {
        let components = endpoint.path.split(separator: "/")
        switch endpoint.method {
        case .GET where endpoint.path.hasSuffix("/activities/calendar"):
            let today = FeedDateFixture.today()
            return try CoreNetworkJSONFixture.response(result: [
                "weekStartDate": endpoint.queryParameters["baseDate"] ?? "", "weekEndDate": today,
                "days": [["date": today, "dayOfWeek": "", "hasRecord": scenario != .emptyFeed]]
            ])
        case .GET where endpoint.path.hasSuffix("/records"):
            if scenario == .feedFailure { throw NetworkError.invalidResponse }
            guard scenario != .emptyFeed, endpoint.queryParameters["date"] == FeedDateFixture.today() else {
                return try CoreNetworkJSONFixture.response(result: ["records": [Any](), "hasNext": false])
            }
            let groupID = components.count > 3 ? Int(components[3]) : nil
            let groupRecords = records.filter {
                groupID == 1 || $0["memberId"] as? Int != 100 || ($0["recordId"] as? Int ?? 0) >= 801
            }
            let cursor = endpoint.queryParameters["cursor"].flatMap(Int.init)
            let start = cursor.flatMap { value in groupRecords.firstIndex { $0["recordId"] as? Int == value }.map { $0 + 1 } } ?? 0
            let size = endpoint.queryParameters["size"].flatMap(Int.init) ?? 20
            let end = min(start + max(size, 0), groupRecords.count)
            let page = Array(groupRecords[start..<end])
            return try CoreNetworkJSONFixture.response(result: [
                "records": page, "hasNext": end < groupRecords.count,
                "nextCursor": end < groupRecords.count ? (page.last?["recordId"] ?? NSNull()) : NSNull()
            ])
        case .POST where endpoint.path == "api/v1/records":
            if scenario == .createFailure { throw NetworkError.invalidResponse }
            let body = try CoreNetworkJSONFixture.body(of: endpoint)
            let isMeal = body["recordType"] as? String == "MEAL"
            insertRecord([
                "recordType": isMeal ? "MEAL" : "EXERCISE", "memberId": 100, "nickname": "내 기록",
                "recordedTime": body["mealTime"] ?? "12:00", "menu": body["menu"] ?? "",
                "exerciseDurationMinutes": (body["exerciseDurationHours"] as? Int ?? 0) * 60 + (body["exerciseDurationMinutes"] as? Int ?? 0),
                "exerciseName": body["exerciseName"] ?? "",
                "imageUrl": "https://feed.demo/\(isMeal ? "meal" : "exercise")/created", "recordingStreakDays": 1
            ])
        case .POST where endpoint.path.hasSuffix("/report"):
            if scenario == .reportFailure { throw NetworkError.invalidResponse }
        case .DELETE where endpoint.path.hasPrefix("api/v1/records/"):
            if scenario == .deleteFailure { throw NetworkError.invalidResponse }
            let recordID = components.last.flatMap { Int($0) }
            records.removeAll { $0["recordId"] as? Int == recordID }
        default:
            throw URLError(.unsupportedURL)
        }
        return try CoreNetworkJSONFixture.response()
    }

    func addDemoRecord() {
        insertRecord([
            "recordType": "MEAL", "memberId": 100, "nickname": "내 기록", "recordedTime": "12:00",
            "menu": "추가한 식사 기록", "exerciseDurationMinutes": 0, "exerciseName": "",
            "imageUrl": "https://feed.demo/meal/\(nextRecordID)", "recordingStreakDays": 1
        ])
    }

    private func insertRecord(_ record: [String: Any]) {
        var record = record
        record["recordId"] = nextRecordID
        nextRecordID += 1
        records.insert(record, at: 0)
    }
}
