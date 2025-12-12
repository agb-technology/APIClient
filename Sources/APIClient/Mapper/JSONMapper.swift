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
}
