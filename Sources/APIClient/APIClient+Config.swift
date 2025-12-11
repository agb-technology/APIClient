//
//  APIClient+Config.swift
//  APIClient
//
//  Created by NANG SAN KHAM on 11/21/25.
//

public struct APIClientConfig: Sendable {
    public let baseURL: String
    public let defaultHeaders: [String: String]
    
    public init(
        baseURL: String,
        defaultHeaders: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
    }
}

public extension APIClientConfig {
    static let `default` = APIClientConfig(
        baseURL: "https://api.example.com",
        defaultHeaders: [
            "Content-Type": "application/json"
        ]
    )
}
