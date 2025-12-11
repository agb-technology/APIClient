//
//  JSONLoader.swift
//  APIClient
//
//  Created by NANG SAN KHAM on 11/21/25.
//

import Foundation

/// JSON 加载工具类，用于从 Bundle 读取并解析 JSON 数据
public struct JSONLoader {
    
    // MARK: - API 异步方法
    
    /// 从指定 JSON 文件加载单个实体
    public static func loadEntity<R: Decodable & ResponseConvertible>(
        fromJSON name: String,
        dtoType: R.Type,
        in bundle: Bundle
    ) async throws -> R.DTO.EntityType {
        
        // 1. 加载原始 JSON 数据
        let any = try loadJSON(named: name, in: bundle)
        
        // 2. 验证 JSON 根对象是字典格式
        guard let mockResponse = any as? [String: Any] else {
            throw JSONLoaderError.invalidJSONFormat(filename: name)
        }
        
        // 3. 转换为 Data 并进行最终解析
        let jsonData = try JSONSerialization.data(withJSONObject: mockResponse, options: [])
        return try JSONMapper.decodeEntity(dtoType, from: jsonData)
    }
    
    /// 从指定 JSON 文件加载实体数组（强制统一为 { "data": [...] } 格式）
    public static func loadEntityList<R: Decodable & ResponseConvertible>(
        fromJSON name: String,
        dtoType: R.Type,
        in bundle: Bundle
    ) async throws -> [R.DTO.EntityType] {
        
        // 1. 加载原始 JSON 数据
        let any = try loadJSON(named: name, in: bundle)
        
        // 2. 验证 JSON 根对象是字典格式且包含 data 数组
        guard let mockResponse = any as? [String: Any],
              let dataArray = mockResponse["data"] as? [[String: Any]] else {
            throw JSONLoaderError.invalidDataFormat(filename: name)
        }
        
        // 3. 解析数组中的每个元素
        var entities: [R.DTO.EntityType] = []
        for item in dataArray {
            let jsonData = try JSONSerialization.data(withJSONObject: item, options: [])
            let entity = try JSONMapper.decodeEntity(dtoType, from: jsonData)
            entities.append(entity)
        }
        
        return entities
    }
    
    // MARK: - Mock 专用同步方法
    
    /// 从 JSON 文件同步加载单个实体（用于 Preview / 单元测试）
    public static func loadEntitySync<R: Decodable & ResponseConvertible>(
        fromJSON name: String,
        dtoType: R.Type,
        in bundle: Bundle
    ) throws -> R.DTO.EntityType {
        let any = try loadJSON(named: name, in: bundle)
        guard let mockResponse = any as? [String: Any] else {
            throw JSONLoaderError.invalidJSONFormat(filename: name)
        }
        let jsonData = try JSONSerialization.data(withJSONObject: mockResponse, options: [])
        return try JSONMapper.decodeEntity(dtoType, from: jsonData)
    }
    
    /// 从 JSON 文件同步加载实体数组（用于 Preview / 单元测试）
    public static func loadEntityListSync<R: Decodable & ResponseConvertible>(
        fromJSON name: String,
        dtoType: R.Type,
        in bundle: Bundle
    ) throws -> [R.DTO.EntityType] {
        let any = try loadJSON(named: name, in: bundle)
        guard let mockResponse = any as? [String: Any],
              let dataArray = mockResponse["data"] as? [[String: Any]] else {
            throw JSONLoaderError.invalidDataFormat(filename: name)
        }
        var entities: [R.DTO.EntityType] = []
        for item in dataArray {
            let jsonData = try JSONSerialization.data(withJSONObject: item, options: [])
            let entity = try JSONMapper.decodeEntity(dtoType, from: jsonData)
            entities.append(entity)
        }
        return entities
    }
    
    // MARK: - 基础 JSON 读取
    
    /// 从指定 JSON 文件加载 JSON 对象
    private static func loadJSON(named name: String, in bundle: Bundle) throws -> Any {
        // 1. 获取文件 URL
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw JSONLoaderError.fileNotFound(filename: name)
        }
        
        print("[APIClient][Mock][JSONLoader] 📦 模拟数据: \(name).json (bundle: \(bundle.bundlePath))")
        
        // 2. 读取并解析数据
        do {
            let data = try Data(contentsOf: url)
            
            // 3. 尝试解析为 [String: Any]
            if let jsonDict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return jsonDict
            } else {
                throw JSONLoaderError.invalidJSONFormat(filename: name)
            }
        } catch {
            throw JSONLoaderError.jsonParsingFailed(filename: name, underlyingError: error)
        }
    }
}
