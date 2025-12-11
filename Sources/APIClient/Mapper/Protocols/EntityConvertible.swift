//
//  EntityConvertible.swift
//  APIClient
//
//  Created by NANG SAN KHAM on 11/21/25.
//

/// DTO 转 Entity 协议
/// 任何遵守此协议的 DTO，都必须实现 `toEntity()` 方法，把自己转换为对应的 Entity
public protocol EntityConvertible {
    associatedtype EntityType
    
    /// 将 DTO 转换为 Entity
    func toEntity() -> EntityType
}
