//
//  JsonUtils.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Foundation

/// JSON 工具
public enum JsonUtils {

    // MARK: - 编码

    /// 对象转 JSON 字符串
    public static func toJsonString<T: Encodable>(_ object: T, prettyPrinted: Bool = false) -> String? {
        let encoder = JSONEncoder()
        if prettyPrinted {
            encoder.outputFormatting = .prettyPrinted
        }
        guard let data = try? encoder.encode(object) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// 对象转 JSON Data
    public static func toJsonData<T: Encodable>(_ object: T) -> Data? {
        try? JSONEncoder().encode(object)
    }

    /// 对象转字典
    public static func toDictionary<T: Encodable>(_ object: T) -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(object) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
    }

    /// 对象转数组字典
    public static func toArray<T: Encodable>(_ object: T) -> [[String: Any]]? {
        guard let data = try? JSONEncoder().encode(object) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String: Any]]
    }

    // MARK: - 解码

    /// JSON 字符串转对象
    public static func fromJsonString<T: Decodable>(_ type: T.Type, json: String) -> T? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    /// JSON Data 转对象
    public static func fromJsonData<T: Decodable>(_ type: T.Type, data: Data) -> T? {
        try? JSONDecoder().decode(type, from: data)
    }

    /// 字典转对象
    public static func fromDictionary<T: Decodable>(_ type: T.Type, dict: [String: Any]) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    // MARK: - 安全解析

    /// 安全解析 JSON 字符串为 Any 对象
    public static func parse(_ jsonString: String) -> Any? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: [.mutableContainers, .allowFragments])
    }

    /// 安全解析 JSON Data 为 Any 对象
    public static func parse(_ data: Data) -> Any? {
        try? JSONSerialization.jsonObject(with: data, options: [.mutableContainers, .allowFragments])
    }

    /// 检查字符串是否是有效 JSON
    public static func isValidJson(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data, options: [])) != nil
    }
}
