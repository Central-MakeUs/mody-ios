//
//  SplashAnalyticsEvent.swift
//  Splash
//
//  Created by 김동준 on 9/3/26.
//

import CommonDomain
import CoreAnalyticsInterface

enum SplashAnalyticsEvent {
    static func loginSucceeded(method: SocialLoginType?) -> AmplitudeLogEvent {
        AmplitudeLogEvent(
            name: "login_succeeded",
            properties: [
                "source": "splash_auto",
                "method": method?.analyticsValue ?? "unknown"
            ]
        )
    }
}

private extension SocialLoginType {
    var analyticsValue: String {
        switch self {
        case .kakao: "kakao"
        case .apple: "apple"
        case .iosTest: "demo"
        }
    }
}
