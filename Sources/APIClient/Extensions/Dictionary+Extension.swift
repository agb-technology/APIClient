//
//  Dictionary+Extension.swift
//  APIClient
//
//  Created by NANG SAN KHAM on 11/21/25.
//

import Foundation

public extension Dictionary where Key == String, Value == Any {
    /// 将字典转换为 `URLQueryItem` 数组，用于拼接到 URL 查询参数中。
    ///
    /// 该属性常用于构建 GET 或 POST 请求的 URL 查询字符串。
    ///
    /// 示例：
    /// ```swift
    /// let params = ["userId": 123, "name": "Alice"]
    /// let queryItems = params.asQueryItems
    /// // 结果: [URLQueryItem(name: "userId", value: "123"), URLQueryItem(name: "name", value: "Alice")]
    /// ```
    var asQueryItems: [URLQueryItem] {
        map { URLQueryItem(name: $0.key, value: "\($0.value)") }
    }
}
