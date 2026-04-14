//
//  MemoryCache.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import Foundation

/// 内存缓存（基于 NSCache）
public final class MemoryCache {

    /// 共享实例
    public static let shared = MemoryCache()

    private let cache = NSCache<NSString, CacheWrapper>()

    /// 总容量限制（字节数），默认 100MB
    public var totalCostLimit: Int {
        get { cache.totalCostLimit }
        set { cache.totalCostLimit = newValue }
    }

    /// 条目数量限制
    public var countLimit: Int {
        get { cache.countLimit }
        set { cache.countLimit = newValue }
    }

    public init() {
        cache.totalCostLimit = 100 * 1024 * 1024
        cache.countLimit = 500
    }

    // MARK: - 存取

    /// 存入缓存
    public func set<T: Codable>(_ object: T, forKey key: String, cost: Int = 0) {
        let wrapper = CacheWrapper(object: object)
        cache.setObject(wrapper, forKey: key as NSString, cost: cost)
    }

    /// 读取缓存
    public func object<T: Codable>(forKey key: String) -> T? {
        cache.object(forKey: key as NSString)?.object as? T
    }

    /// 是否存在
    public func contains(key: String) -> Bool {
        cache.object(forKey: key as NSString) != nil
    }

    /// 删除
    public func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    /// 清空所有
    public func removeAll() {
        cache.removeAllObjects()
    }
}

// MARK: - Cache Wrapper

private class CacheWrapper {
    let object: Any

    init(object: Any) {
        self.object = object
    }
}
