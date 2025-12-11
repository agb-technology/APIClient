//
//  EntityConvertible+Extension.swift
//  APIClient
//
//  Created by NANG SAN KHAM on 11/21/25.
//

extension String: EntityConvertible {
    public typealias EntityType = String
    public func toEntity() -> String { self }
}

extension Int: EntityConvertible {
    public typealias EntityType = Int
    public func toEntity() -> Int { self }
}

extension Double: EntityConvertible {
    public typealias EntityType = Double
    public func toEntity() -> Double { self }
}

extension Bool: EntityConvertible {
    public typealias EntityType = Bool
    public func toEntity() -> Bool { self }
}

extension Array: EntityConvertible where Element: EntityConvertible {
    public typealias EntityType = [Element.EntityType]
    public func toEntity() -> [Element.EntityType] {
        return self.map { $0.toEntity() }
    }
}
