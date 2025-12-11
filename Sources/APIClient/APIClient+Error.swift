//
//  APIClient+Error.swift
//  APIClient
//
//  Created by NANG SAN KHAM on 11/21/25.
//

import Foundation

public enum APIClientError: Error, LocalizedError {
    case network(APIClientErrorCode, underlying: URLError?)
    case url(APIClientErrorCode)
    case request(APIClientErrorCode)
    case response(APIClientErrorCode, statusCode: Int?, data: Data?)
    case decoding(APIClientErrorCode, underlying: Error?)
    case unknown(APIClientErrorCode, underlying: Error?)
    
    private var prefix: String {
        return "[APIClient][APIClientError]"
    }
    
    // MARK: - Code
    
    // 错误码
    public var code: APIClientErrorCode {
        switch self {
        case .network(let code, _): return code
        case .url(let code): return code
        case .request(let code): return code
        case .response(let code, _, _): return code
        case .decoding(let code, _): return code
        case .unknown(let code, _): return code
        }
    }
    
    // MARK: - Error Description
    
    // 错误描述
    public var errorDescription: String? {
        switch self {
        case .network(let code, let error):
            let err: String
            if let error = error {
                err = "(\(error.failureURLString ?? "N/A")) -> \(error.localizedDescription)"
            } else {
                err = "(N/A) -> 无具体错误信息"
            }
            
            switch code {
            case .networkUnavailable: return "\(prefix) 网络连接不可用，请检查网络设置后重试。err: \(err)"
            case .networkTimeout: return "\(prefix) 网络请求超时，请稍后再试。err: \(err)"
            case .networkConnectionLost: return "\(prefix) 网络连接中断，请重试。err: \(err)"
            case .sslError: return "\(prefix) SSL 安全连接失败。err: \(err)"
            case .dnsResolutionFailed: return "\(prefix) DNS 解析失败，请检查网络。err: \(err)"
            default: return "\(prefix) 网络错误，请稍后重试。err: \(err)"
            }
            
        case .url(let code):
            switch code {
            case .invalidURL: return "\(prefix) 无效的请求地址"
            case .malformedURL: return "\(prefix) 请求地址格式错误"
            default: return "\(prefix) URL 错误"
            }
            
        case .request(let code):
            switch code {
            case .invalidRequest: return "\(prefix) 无效的请求参数"
            case .requestTimeout: return "\(prefix) 请求超时，请稍后再试"
            case .requestCancelled: return "\(prefix) 请求已被取消"
            default: return "\(prefix) 请求错误"
            }
            
        case .response(_, let statusCode, let data):
            let responseString: String
            if let data = data {
                responseString = String(data: data, encoding: .utf8) ?? "\(prefix) 无法解析响应内容"
            } else {
                responseString = "\(prefix) 无响应数据"
            }
            // 404 就不显示responseString了
            if statusCode == 404 {
                return "\(prefix) 服务器响应错误。状态码: \(statusCode ?? -1)。"
            } else {
                return "\(prefix) 服务器响应错误。状态码: \(statusCode ?? -1)，响应: \(responseString)"
            }
            
            
        case .decoding(let code, _):
            switch code {
            case .decodingError: return "\(prefix) 数据解析失败"
            case .encodingError: return "\(prefix) 数据编码失败"
            case .invalidJSON: return "\(prefix) 无效的 JSON 格式"
            case .dataCorrupted: return "\(prefix) 返回的数据已损坏或不完整"
            default: return "\(prefix) 数据处理错误"
            }
            
        case .unknown(_, let error):
            return "\(prefix) 发生未知错误，请稍后重试。\(error.debugDescription)"
        }
    }
    
    // MARK: - Response Data Access
    
    public var respData: Data? {
        switch self {
        case .response(_, _, let data):
            return data
        default:
            return nil
        }
    }
    
    // MARK: - Message
    
    /// 根据错误类型返回对应的本地化消息
    public static func localizedErrorDescription(_ code: APIClientErrorCode) -> LocalizedStringResource {
        LocalizedStringResource(
            code.localizedKey,
            bundle: .module
        )
    }
}
