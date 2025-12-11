//
//  JSONDecoder+Extension.swift
//  APIClient
//
//  Created by NANG SAN KHAM on 11/21/25.
//

import Foundation

internal extension JSONDecoder {
    func safeDecode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try self.decode(type, from: data)
        } catch {
            throw APIClientError.decoding(.decodingError, underlying: error)
        }
    }
}
