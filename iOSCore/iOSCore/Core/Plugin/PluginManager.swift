//
//  PluginManager.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Foundation

/// 插件协议
public protocol PluginProtocol: AnyObject {
    /// 插件标识
    static var pluginIdentifier: String { get }

    /// 插件加载时调用
    func onLoad()

    /// 插件卸载时调用（可选）
    func onUnload()
}

/// 插件管理器（泛型注册表）
public final class PluginManager {

    public static let shared = PluginManager()

    private var plugins: [String: any PluginProtocol] = [:]
    private let lock = NSLock()

    private init() {}

    // MARK: - 注册插件

    /// 注册插件
    public func register<P: PluginProtocol>(_ plugin: P) {
        let key = P.pluginIdentifier
        lock.lock()
        let existing = plugins[key]
        plugins[key] = plugin
        lock.unlock()

        existing?.onUnload()
        plugin.onLoad()
    }

    /// 获取插件
    public func plugin<P: PluginProtocol>(_ type: P.Type) -> P? {
        let key = type.pluginIdentifier
        lock.lock()
        defer { lock.unlock() }
        return plugins[key] as? P
    }

    /// 获取所有已注册插件
    public func allPlugins() -> [any PluginProtocol] {
        lock.lock()
        defer { lock.unlock() }
        return Array(plugins.values)
    }

    /// 是否已注册
    public func isRegistered<P: PluginProtocol>(_ type: P.Type) -> Bool {
        let key = type.pluginIdentifier
        lock.lock()
        defer { lock.unlock() }
        return plugins[key] != nil
    }

    // MARK: - 移除插件

    /// 移除插件
    public func unregister<P: PluginProtocol>(_ type: P.Type) {
        let key = type.pluginIdentifier
        lock.lock()
        let plugin = plugins.removeValue(forKey: key)
        lock.unlock()

        plugin?.onUnload()
    }

    /// 移除所有插件
    public func unregisterAll() {
        lock.lock()
        let all = plugins
        plugins.removeAll()
        lock.unlock()

        for plugin in all.values {
            plugin.onUnload()
        }
    }
}
