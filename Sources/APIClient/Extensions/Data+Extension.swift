//
//  Data+Extension.swift
//  APIClient
//
//  Created by NANG SAN KHAM on 11/21/25.
//

import Foundation

public extension Data {
    // 将当前 JSON 对象转换为指定类型的模型
    func fromJSON<T: Decodable>(_ type: T.Type) throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
    
    /// 将数据转换为格式化后的 JSON 字符串，如果无法解析则返回原始字符串或错误信息。
    var prettyPrintedJSONString: String {
        guard !self.isEmpty else {
            return "无响应体内容"
        }
        
        guard let object = try? JSONSerialization.jsonObject(with: self),
              let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
              let string = String(data: data, encoding: .utf8) else {
            return String(data: self, encoding: .utf8) ?? "无法解码响应体内容"
        }
        return string
    }
}
