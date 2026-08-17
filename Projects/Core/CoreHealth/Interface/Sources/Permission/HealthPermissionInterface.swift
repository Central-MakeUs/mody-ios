//
//  HealthPermissionInterface.swift
//  CoreHealthInterface
//
//  Created by 김동준 on 8/4/26.
//

public protocol HealthPermissionInterface {
    // MARK: HealthKit 권한 팝업을 다시 띄울 필요가 있는지 확인. true: 권한 요청이 필요, false: 이미 요청했거나 요청할 필요 없음
    func shouldShowHealthPermissionPrompt() async -> Bool

    // MARK: 실제 HealthKit 권한 팝업 띄움, 사용자가 거부해도 true 일 수 있음. true -> 에러 없이 팝업을 띄웠다는 것을 의미
    func requestHealthPermission() async -> Bool
}
