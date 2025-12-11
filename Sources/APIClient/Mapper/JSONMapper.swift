//
//  JSONMapper.swift
//  APIClient
//
//  Created by NANG SAN KHAM on 11/21/25.
//

import Foundation

// JSON 解析工具
public enum JSONMapper {
    /// 解析任意遵守 `Decodable` 的类型
    /// - Parameters:
    ///   - type: 遵守 `Decodable` 的目标类型
    ///   - jsonData: JSON 数据
    /// - Returns: 解析后的对象
    /// - 说明: 不依赖 `ResponseConvertible`，直接返回 DTO 本身
    public static func decodeDTO<T: Decodable>(_ type: T.Type, from jsonData: Data) throws -> T {
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
    
    /// 解析遵守 `Decodable & ResponseConvertible` 的 DTO 并提取对应的 Entity
    /// - Parameters:
    ///   - type: 遵守 `Decodable & ResponseConvertible` 的 DTO 类型
    ///   - jsonData: JSON 数据
    /// - Returns: DTO 转换后的 Entity 对象
    /// - 说明:
    ///   1. 先用 JSONDecoder 解析 JSON 成 DTO 对象
    ///   2. 再通过 `extractEntity()` 方法转换成 Entity
    public static func decodeEntity<R: Decodable & ResponseConvertible>(
        _ type: R.Type,
        from jsonData: Data
    ) throws -> R.DTO.EntityType {
        let decoded = try jsonData.fromJSON(type)
        return try decoded.extractEntity()
    }
}
