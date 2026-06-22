//
//  HTTPMethod.swift
//  APIClient
//
//  Created by NANG SAN KHAM on 11/21/25.
//

public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, HEAD

    /// Safe to send more than once without additional side effects. Used to decide
    /// whether a request may be transparently retried after a connection-level
    /// failure. POST is excluded so it is never silently re-submitted.
    var isIdempotent: Bool {
        switch self {
        case .GET, .HEAD, .PUT, .DELETE: return true
        case .POST: return false
        }
    }
}
