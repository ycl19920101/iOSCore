//
//  AppConfig.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Combine
import Foundation

/// 应用配置（泛型，自动持久化到 UserDefaults）
///
/// 用法:
/// ```
/// struct ThemeConfig: Codable {
///     var darkMode: Bool = false
///     var fontSize: Int = 14
/// }
/// let theme = AppConfig<ThemeConfig>(key: "theme_config")
/// theme.value.darkMode = true
/// theme.save() // 自动持久化
/// ```
public final class AppConfig<T: Codable> {

    /// 当前配置值
    public private(set) var value: T

    /// 存储键
    public let key: String

    /// 变更通知 Publisher
    public let didChange = PassthroughSubject<T, Never>()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// 初始化配置
    /// - Parameters:
    ///   - key: UserDefaults 存储键
    ///   - defaultValue: 默认值（可选，不传则使用 T 的 init()）
    public init(key: String, defaultValue: T) {
        self.key = key
        self.value = defaultValue

        if let data = defaults.data(forKey: key),
           let loaded = try? decoder.decode(T.self, from: data) {
            self.value = loaded
        }
    }

    /// 保存当前值到 UserDefaults
    public func save() {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
        didChange.send(value)
    }

    /// 更新值并保存
    public func update(_ update: (inout T) -> Void) {
        update(&value)
        save()
    }

    /// 重置为默认值
    public func reset(to defaultValue: T) {
        value = defaultValue
        save()
    }

    /// 删除存储
    public func remove() {
        defaults.removeObject(forKey: key)
    }
}
