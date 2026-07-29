//
//  ServerErrorCode.swift
//  CommonDomain
//
//  Created by 김동준 on 7/10/26
//

public enum ServerErrorCode {
    case group301
    case group304
    
    public var code: String {
        switch self {
        case .group301: "GROUP301"
        case .group304: "GROUP304"
        }
    }
}
