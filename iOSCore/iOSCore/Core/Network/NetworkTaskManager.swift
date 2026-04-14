//
//  NetworkTaskManager.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Alamofire
import Foundation

/// 网络任务管理器（请求取消/去重）
public final class NetworkTaskManager {

    public static let shared = NetworkTaskManager()

    /// 活跃请求
    private var activeRequests: [String: Request] = [:]
    private let lock = NSLock()

    private init() {}

    // MARK: - 任务标识

    /// 生成请求唯一标识
    public static func taskIdentifier(url: String, method: HTTPMethod = .get, parameters: Parameters? = nil) -> String {
        var components = [method.rawValue, url]
        if let params = parameters {
            let sorted = params.sorted { $0.key < $1.key }
            components.append(sorted.map { "\($0)=\($1)" }.joined(separator: "&"))
        }
        return components.joined(separator: "|")
    }

    // MARK: - 取消请求

    /// 取消指定 URL 的所有请求
    public func cancelRequests(for url: String) {
        lock.lock()
        let matching = activeRequests.filter { $0.key.contains(url) }
        for key in matching.keys {
            activeRequests.removeValue(forKey: key)
        }
        lock.unlock()

        for (_, request) in matching {
            request.cancel()
        }
    }

    /// 取消所有请求
    public func cancelAll() {
        lock.lock()
        let all = activeRequests
        activeRequests.removeAll()
        lock.unlock()

        for (_, request) in all {
            request.cancel()
        }
    }

    // MARK: - 请求去重

    /// 检查并取消重复请求（返回 true 表示已有相同请求被取消）
    @discardableResult
    public func deduplicate(url: String, method: HTTPMethod = .get, parameters: Parameters? = nil) -> Bool {
        let identifier = NetworkTaskManager.taskIdentifier(url: url, method: method, parameters: parameters)

        lock.lock()
        if let existing = activeRequests[identifier] {
            activeRequests.removeValue(forKey: identifier)
            lock.unlock()
            existing.cancel()
            return true
        }
        lock.unlock()
        return false
    }

    // MARK: - 注册/移除

    /// 注册活跃请求
    public func register(request: Request, identifier: String) {
        lock.lock()
        activeRequests[identifier] = request
        lock.unlock()
    }

    /// 移除已完成的请求
    public func unregister(identifier: String) {
        lock.lock()
        activeRequests.removeValue(forKey: identifier)
        lock.unlock()
    }
}
