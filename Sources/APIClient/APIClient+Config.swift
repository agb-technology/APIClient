//
//  APIClient+Config.swift
//  APIClient
//
//  Created by NANG SAN KHAM on 11/21/25.
//

import Foundation

public struct APIClientConfig: Sendable {
    public let baseURL: String
    public let defaultHeaders: [String: String]
    public let requestTimeout: TimeInterval
    /// Which fields the debug logger prints. Defaults to everything; pass a subset
    /// to narrow it (e.g. `[.method, .url, .statusCode]`) or `[]` to silence it.
    public let logOptions: APILogOptions

    public init(
        baseURL: String,
        defaultHeaders: [String: String] = [:],
        requestTimeout: TimeInterval = 30,
        logOptions: APILogOptions = .all
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.requestTimeout = requestTimeout
        self.logOptions = logOptions
    }
}

public extension APIClientConfig {
    static let `default` = APIClientConfig(
        baseURL: "https://api.example.com",
        defaultHeaders: [
            "Content-Type": "application/json"
        ],
        requestTimeout: 30
    )
}
