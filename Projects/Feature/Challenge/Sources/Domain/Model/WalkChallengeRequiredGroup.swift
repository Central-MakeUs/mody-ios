//
//  WalkChallengeRequiredGroup.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

public enum WalkChallengeRequiredGroup: String, Equatable {
    case seoulIncheon = "서울-인천"
    case seoulCheonan = "서울-천안"
    case seoulDaejeon = "서울-대전"
    case seoulDaegu = "서울-대구"
    case seoulBusan = "서울-부산"
    case seoulJeju = "서울-제주"
    
    var title: String {
        switch self {
        case .seoulIncheon:
            return "인천까지 걸어가기 챌린지"
        case .seoulCheonan:
            return "천안까지 걸어가기 챌린지"
        case .seoulDaejeon:
            return "대전까지 걸어가기 챌린지"
        case .seoulDaegu:
            return "대구까지 걸어가기 챌린지"
        case .seoulBusan:
            return "부산까지 걸어가기 챌린지"
        case .seoulJeju:
            return "제주까지 걸어가기 챌린지"
        }
    }
}
