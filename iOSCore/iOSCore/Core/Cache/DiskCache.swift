//
//  DiskCache.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import Foundation

/// 磁盘缓存
public final class DiskCache {

    /// 缓存目录
    public let directory: URL

    /// 文件扩展名
    public let fileExtension: String

    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.ioscore.diskcache", attributes: .concurrent)
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// 初始化
    /// - Parameters:
    ///   - directory: 缓存目录路径
    ///   - fileExtension: 文件扩展名
    public init(directory: URL? = nil, fileExtension: String = "cache") {
        self.fileExtension = fileExtension
        if let directory = directory {
            self.directory = directory
        } else {
            self.directory = FileUtils.cachesDirectory.appendingPathComponent("DiskCache")
        }
        try? fileManager.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }

    // MARK: - 存取

    /// 存入缓存
    public func set<T: Codable>(_ object: T, forKey key: String, ttl: TimeInterval? = nil) {
        let entry = CacheEntry(data: object, expiration: ttl.map { Date().addingTimeInterval($0) })
        guard let data = try? encoder.encode(entry) else { return }
        let fileURL = cacheFileURL(forKey: key)
        queue.sync(flags: .barrier) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    /// 读取缓存
    public func object<T: Codable>(forKey key: String) -> T? {
        let fileURL = cacheFileURL(forKey: key)
        var data: Data?
        queue.sync {
            data = try? Data(contentsOf: fileURL)
        }
        guard let data = data else { return nil }

        guard let entry = try? decoder.decode(CacheEntry<T>.self, from: data) else { return nil }

        // 检查过期
        if let expiration = entry.expiration, expiration < Date() {
            remove(forKey: key)
            return nil
        }

        return entry.data
    }

    /// 是否存在（且未过期）
    public func contains(key: String) -> Bool {
        let fileURL = cacheFileURL(forKey: key)
        var exists = false
        queue.sync {
            exists = fileManager.fileExists(atPath: fileURL.path)
        }
        if exists {
            // 检查是否过期（需要读取文件）
            var data: Data?
            queue.sync {
                data = try? Data(contentsOf: fileURL)
            }
            if let data = data,
               let wrapper = try? decoder.decode(CacheEntryWrapper.self, from: data),
               let expiration = wrapper.expiration, expiration < Date() {
                remove(forKey: key)
                return false
            }
        }
        return exists
    }

    /// 删除
    public func remove(forKey key: String) {
        let fileURL = cacheFileURL(forKey: key)
        queue.sync(flags: .barrier) {
            try? fileManager.removeItem(at: fileURL)
        }
    }

    /// 清空所有
    public func removeAll() {
        queue.sync(flags: .barrier) {
            try? fileManager.removeItem(at: directory)
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    // MARK: - 信息

    /// 缓存大小
    public func totalSize() -> UInt64 {
        FileUtils.directorySize(at: directory)
    }

    /// 缓存条目数
    public func totalCount() -> Int {
        (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil))?.count ?? 0
    }

    /// 清除过期缓存
    public func clearExpired() {
        guard let files = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return }
        for fileURL in files {
            if let data = try? Data(contentsOf: fileURL),
               let wrapper = try? decoder.decode(CacheEntryWrapper.self, from: data),
               let expiration = wrapper.expiration, expiration < Date() {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }

    // MARK: - Private

    private func cacheFileURL(forKey key: String) -> URL {
        let filename = EncryptUtils.md5(key)
        return directory.appendingPathComponent("\(filename).\(fileExtension)")
    }
}

// MARK: - Cache Entry

private struct CacheEntry<T: Codable>: Codable {
    let data: T
    let expiration: Date?
}

private struct CacheEntryWrapper: Codable {
    let expiration: Date?
}
