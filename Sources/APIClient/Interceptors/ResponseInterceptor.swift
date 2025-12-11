//
//  ResponseInterceptor.swift
//  APIClient
//
//  Created by NANG SAN KHAM on 11/21/25.
//

import Foundation

public protocol ResponseInterceptor: Sendable {
    func intercept(
        data: Data,
        response: URLResponse,
        request: URLRequest,
        session: URLSession
    ) async throws -> (Data, URLResponse)
}
