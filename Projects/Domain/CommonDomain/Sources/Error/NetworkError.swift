//
//  NetworkError.swift
//  CommonDomain
//
//  Created by 김동준 on 7/3/26
//

public enum NetworkError: Error, Equatable {
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case tooManyRequests
    case serverUnavailable
    case networkUnavailable
    case timeout
    case invalidResponse
    indirect case serverError(code: String?, message: String?, fallback: NetworkError)
    case unknown
}

public extension NetworkError {
    var title: String {
        switch self {
        case .unauthorized:
            return "인증 오류"
        case .networkUnavailable:
            return "네트워크 오류"
        case .timeout:
            return "요청 시간 초과"
        case .serverUnavailable:
            return "서버 오류"
        case .serverError:
            return "요청 오류"
        default:
            return "오류"
        }
    }

    var message: String {
        switch self {
        case .badRequest:
            return "잘못된 요청이에요. 다시 시도해 주세요."
        case .unauthorized:
            return "로그인 정보가 만료되었어요. 다시 로그인해 주세요."
        case .forbidden:
            return "요청 권한이 없어요."
        case .notFound:
            return "요청한 정보를 찾을 수 없어요."
        case .tooManyRequests:
            return "요청이 너무 많아요. 잠시 후 다시 시도해 주세요."
        case .serverUnavailable:
            return "서버가 잠시 불안정해요. 잠시 후 다시 시도해 주세요."
        case .networkUnavailable:
            return "인터넷 연결을 확인해 주세요."
        case .timeout:
            return "응답 시간이 초과됐어요. 다시 시도해 주세요."
        case .invalidResponse:
            return "응답을 처리하지 못했어요. 다시 시도해 주세요."
        case let .serverError(code, message, fallback):
            return "[\(String(describing: code))]: \(String(describing: message))"
        case .unknown:
            return "알 수 없는 오류가 발생했어요. 다시 시도해 주세요."
        }
    }
}
