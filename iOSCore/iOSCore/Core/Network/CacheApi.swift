//
//  CacheApi.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Alamofire
import Foundation

/// 缓存策略
public enum CachePolicy {
    /// 只从网络获取
    case networkOnly
    /// 只从缓存获取
    case cacheOnly
    /// 先读缓存，同时请求网络并更新缓存
    case cacheThenNetwork
    /// 先请求网络，失败则读缓存
    case networkElseCache
    /// 有缓存且未过期则用缓存，否则请求网络
    case cacheElseNetwork(maxAge: TimeInterval)
}

/// 缓存 API（网络请求 + 本地缓存）
public final class CacheApi {

    public static let shared = CacheApi()

    private let cacheDirectory: URL
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.ioscore.cacheapi", attributes: .concurrent)

    private init() {
        cacheDirectory = FileUtils.cachesDirectory.appendingPathComponent("NetworkCache")
        FileUtils.createDirectory(at: cacheDirectory)
    }

    // MARK: - 请求

    /// 带缓存的 GET 请求
    public func get<T: Decodable>(
        _ url: String,
        parameters: Parameters? = nil,
        cachePolicy: CachePolicy = .networkElseCache,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let cacheKey = buildCacheKey(url: url, parameters: parameters)

        switch cachePolicy {
        case .networkOnly:
            return try await fetchFromNetwork(url: url, parameters: parameters, cacheKey: cacheKey, decoder: decoder)

        case .cacheOnly:
            guard let cached: T = readCache(key: cacheKey, decoder: decoder) else {
                throw NetworkError.invalidResponse
            }
            return cached

        case .cacheThenNetwork:
            // 先返回缓存（如果有），同时后台请求网络
            if let cached: T = readCache(key: cacheKey, decoder: decoder) {
                // 后台更新缓存（不等待）
                Task {
                    _ = try? await fetchFromNetwork(url: url, parameters: parameters, cacheKey: cacheKey, decoder: decoder) as T
                }
                return cached
            }
            return try await fetchFromNetwork(url: url, parameters: parameters, cacheKey: cacheKey, decoder: decoder)

        case .networkElseCache:
            do {
                return try await fetchFromNetwork(url: url, parameters: parameters, cacheKey: cacheKey, decoder: decoder)
            } catch {
                guard let cached: T = readCache(key: cacheKey, decoder: decoder) else {
                    throw error
                }
                return cached
            }

        case .cacheElseNetwork(let maxAge):
            if let cached: T = readCache(key: cacheKey, decoder: decoder, maxAge: maxAge) {
                return cached
            }
            return try await fetchFromNetwork(url: url, parameters: parameters, cacheKey: cacheKey, decoder: decoder)
        }
    }

    // MARK: - 清理

    /// 清除所有缓存
    public func clearCache() {
        FileUtils.remove(at: cacheDirectory)
        FileUtils.createDirectory(at: cacheDirectory)
    }

    /// 清除过期缓存
    public func clearExpiredCache() {
        let contents = FileUtils.contentsOfDirectory(at: cacheDirectory)
        let now = Date()
        for fileURL in contents {
            if let attrs = try? fileManager.attributesOfItem(atPath: fileURL.path),
               let modDate = attrs[.modificationDate] as? Date,
               now.timeIntervalSince(modDate) > 7 * 24 * 3600 {
                FileUtils.remove(at: fileURL)
            }
        }
    }

    /// 缓存大小
    public func cacheSize() -> String {
        FileUtils.formatSize(FileUtils.directorySize(at: cacheDirectory))
    }

    // MARK: - Private

    private func fetchFromNetwork<T: Decodable>(
        url: String,
        parameters: Parameters?,
        cacheKey: String,
        decoder: JSONDecoder
    ) async throws -> T {
        let data: Data = try await NetworkManager.shared.get(url, parameters: parameters)
        let result = try decoder.decode(T.self, from: data)
        writeCache(data: data, key: cacheKey)
        return result
    }

    private func buildCacheKey(url: String, parameters: Parameters?) -> String {
        var key = url
        if let params = parameters {
            let sorted = params.sorted { $0.key < $1.key }
            key += "?" + sorted.map { "\($0)=\($1)" }.joined(separator: "&")
        }
        return EncryptUtils.md5(key)
    }

    private func cacheFileURL(key: String) -> URL {
        cacheDirectory.appendingPathComponent(key)
    }

    private func writeCache(data: Data, key: String) {
        let url = cacheFileURL(key: key)
        FileUtils.write(data, to: url)
    }

    private func readCache<T: Decodable>(key: String, decoder: JSONDecoder, maxAge: TimeInterval? = nil) -> T? {
        let url = cacheFileURL(key: key)
        guard FileUtils.exists(at: url) else { return nil }

        // 检查过期
        if let maxAge = maxAge {
            if let attrs = try? fileManager.attributesOfItem(atPath: url.path),
               let modDate = attrs[.modificationDate] as? Date,
               Date().timeIntervalSince(modDate) > maxAge {
                return nil
            }
        }

        guard let data = FileUtils.readData(at: url) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
}
