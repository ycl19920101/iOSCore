//
//  KVCache.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import Foundation

/// KV 缓存（内存 + 磁盘二级缓存）
public final class KVCache {

    public static let shared = KVCache()

    private let memoryCache = MemoryCache()
    private let diskCache: DiskCache

    public init(diskDirectory: URL? = nil) {
        self.diskCache = DiskCache(directory: diskDirectory)
    }

    // MARK: - 存取

    /// 存入缓存
    /// - Parameters:
    ///   - object: 缓存对象（Codable）
    ///   - key: 缓存键
    ///   - ttl: 过期时间（秒），nil 表示永不过期
    public func set<T: Codable>(_ object: T, forKey key: String, ttl: TimeInterval? = nil) {
        memoryCache.set(object, forKey: key)
        diskCache.set(object, forKey: key, ttl: ttl)
    }

    /// 读取缓存（先查内存，再查磁盘）
    public func object<T: Codable>(forKey key: String) -> T? {
        // 先查内存
        if let cached: T = memoryCache.object(forKey: key) {
            return cached
        }
        // 再查磁盘
        if let cached: T = diskCache.object(forKey: key) {
            // 回填内存
            memoryCache.set(cached, forKey: key)
            return cached
        }
        return nil
    }

    /// 是否存在
    public func contains(key: String) -> Bool {
        memoryCache.contains(key: key) || diskCache.contains(key: key)
    }

    /// 删除
    public func remove(forKey key: String) {
        memoryCache.remove(forKey: key)
        diskCache.remove(forKey: key)
    }

    // MARK: - 批量操作

    /// 存入多个
    public func setObjects<T: Codable>(_ objects: [(key: String, value: T)], ttl: TimeInterval? = nil) {
        for item in objects {
            set(item.value, forKey: item.key, ttl: ttl)
        }
    }

    /// 删除多个
    public func remove(forKeys keys: [String]) {
        for key in keys {
            remove(forKey: key)
        }
    }

    // MARK: - 清理

    /// 清空所有
    public func removeAll() {
        memoryCache.removeAll()
        diskCache.removeAll()
    }

    /// 清除过期缓存
    public func clearExpired() {
        diskCache.clearExpired()
    }

    // MARK: - 信息

    /// 磁盘缓存大小
    public func diskSize() -> String {
        FileUtils.formatSize(diskCache.totalSize())
    }

    /// 磁盘缓存条目数
    public func diskCount() -> Int {
        diskCache.totalCount()
    }
}
