//
//  APIClient+ErrorCode.swift
//  APIClient
//
//  Created by NANG SAN KHAM on 11/21/25.
//

public enum APIClientErrorCode: Int, Sendable {
    
    // MARK: - 网络相关错误 1000-1999
    
    /// 无网络连接
    case networkUnavailable = 1000
    
    /// 网络请求超时
    case networkTimeout = 1001
    
    /// 网络连接中断
    case networkConnectionLost = 1002
    
    /// SSL证书验证失败
    case sslError = 1003
    
    /// DNS解析失败
    case dnsResolutionFailed = 1004
    
    // MARK: - URL 相关错误 2000-2999
    
    /// 无效的URL地址
    case invalidURL = 2000
    
    /// URL格式错误
    case malformedURL = 2001
    
    // MARK: - 请求相关错误 3000-3999
    
    /// 无效的请求参数
    case invalidRequest = 3000
    
    /// 请求超时
    case requestTimeout = 3001
    
    /// 请求被取消
    case requestCancelled = 3002
    
    // MARK: - 响应相关错误 4000-4999
    
    /// 无效的服务器响应
    case invalidResponse = 4000
    
    /// HTTP协议错误
    case httpError = 4001
    
    /// 未授权访问（需要登录）
    case unauthorized = 4002
    
    /// 访问被禁止（权限不足）
    case forbidden = 4003
    
    /// 请求的资源不存在
    case notFound = 4004
    
    /// 服务器内部错误
    case serverError = 4005
    
    /// 服务暂时不可用
    case serviceUnavailable = 4006
    
    // MARK: - 数据解析错误 5000-5999
    
    /// 数据解析失败
    case decodingError = 5000
    
    /// 数据编码失败
    case encodingError = 5001
    
    /// 无效的JSON格式
    case invalidJSON = 5002
    
    /// 数据损坏或不完整
    case dataCorrupted = 5003
    
    // MARK: - 未知错误
    
    /// 未知错误
    case unknownError = 9999
}
