//
//  ResponseConvertible.swift
//  APIClient
//
//  Created by NANG SAN KHAM on 11/21/25.
//

// API 响应协议
public protocol ResponseConvertible {
    associatedtype DTO: Decodable & EntityConvertible
    
    func extractEntity() throws -> DTO.EntityType
}
