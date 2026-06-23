//
//  APILogOptions.swift
//  APIClient
//

import Foundation

/// Selects which fields the debug request/response logger prints. Combine the
/// fields you want; pass `.all` (the default in `APIClientConfig`) to print
/// everything, or `[]` to silence the logger entirely.
public struct APILogOptions: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let method        = APILogOptions(rawValue: 1 << 0)
    public static let url           = APILogOptions(rawValue: 1 << 1)
    public static let requestHeader = APILogOptions(rawValue: 1 << 2)
    public static let requestBody   = APILogOptions(rawValue: 1 << 3)
    public static let statusCode    = APILogOptions(rawValue: 1 << 4)
    public static let responseBody  = APILogOptions(rawValue: 1 << 5)
    /// Network round-trip time of the `session.data` call, in milliseconds.
    public static let duration      = APILogOptions(rawValue: 1 << 6)

    /// Every field — the default.
    public static let all: APILogOptions = [
        .method, .url, .requestHeader, .requestBody, .statusCode, .responseBody, .duration
    ]
}
