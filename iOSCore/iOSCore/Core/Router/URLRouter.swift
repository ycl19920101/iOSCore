//
//  URLRouter.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Foundation

/// URL 路由错误
public enum RouterError: Error {
    case routeNotFound(String)
    case invalidURL
    case parameterMismatch
}

/// 路由上下文
public struct RouteContext {
    /// 原始 URL
    public let url: URL
    /// 路径参数（如 /user/:id → ["id": "123"]）
    public let pathParameters: [String: String]
    /// 查询参数
    public let queryParameters: [String: String]
    /// 附加数据
    public var userInfo: [AnyHashable: Any]

    public init(url: URL, pathParameters: [String: String] = [:], queryParameters: [String: String] = [:], userInfo: [AnyHashable: Any] = [:]) {
        self.url = url
        self.pathParameters = pathParameters
        self.queryParameters = queryParameters
        self.userInfo = userInfo
    }
}

/// 路由处理闭包
public typealias RouteHandler = (RouteContext) -> Bool

/// URL 路由器
public final class URLRouter {

    public static let shared = URLRouter()

    private var routes: [(pattern: String, regex: NSRegularExpression, handler: RouteHandler)] = []
    private let lock = NSLock()

    private init() {}

    // MARK: - 注册路由

    /// 注册路由模式
    /// - Parameters:
    ///   - pattern: 路由模式，支持路径参数如 "ycl://user/:id/profile"
    ///   - handler: 处理闭包，返回 true 表示已处理
    @discardableResult
    public func register(_ pattern: String, handler: @escaping RouteHandler) -> Bool {
        guard let regex = patternToRegex(pattern) else { return false }
        lock.lock()
        routes.append((pattern: pattern, regex: regex, handler: handler))
        lock.unlock()
        return true
    }

    /// 移除路由
    public func unregister(_ pattern: String) {
        lock.lock()
        routes.removeAll { $0.pattern == pattern }
        lock.unlock()
    }

    // MARK: - 打开 URL

    /// 打开 URL 字符串
    @discardableResult
    public func open(_ urlString: String, userInfo: [AnyHashable: Any] = [:]) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return open(url, userInfo: userInfo)
    }

    /// 打开 URL
    @discardableResult
    public func open(_ url: URL, userInfo: [AnyHashable: Any] = [:]) -> Bool {
        let urlString = url.absoluteString
        let range = NSRange(urlString.startIndex..., in: urlString)

        lock.lock()
        let currentRoutes = routes
        lock.unlock()

        for route in currentRoutes {
            if let match = route.regex.firstMatch(in: urlString, options: [], range: range) {
                // 提取路径参数
                var pathParams: [String: String] = [:]
                let namedRanges = route.regex.namedCaptureGroups
                for (index, name) in namedRanges.enumerated() {
                    let paramRange = match.range(at: index + 1)
                    if paramRange.location != NSNotFound, let range = Range(paramRange, in: urlString) {
                        pathParams[name] = String(urlString[range])
                    }
                }

                // 提取查询参数
                var queryParams: [String: String] = [:]
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let queryItems = components.queryItems {
                    for item in queryItems {
                        queryParams[item.name] = item.value ?? ""
                    }
                }

                let context = RouteContext(
                    url: url,
                    pathParameters: pathParams,
                    queryParameters: queryParams,
                    userInfo: userInfo
                )

                return route.handler(context)
            }
        }

        return false
    }

    /// 判断是否可以打开 URL
    public func canOpen(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        let range = NSRange(urlString.startIndex..., in: urlString)

        lock.lock()
        let currentRoutes = routes
        lock.unlock()

        return currentRoutes.contains { $0.regex.firstMatch(in: urlString, options: [], range: range) != nil }
    }

    // MARK: - Private

    private func patternToRegex(_ pattern: String) -> NSRegularExpression? {
        // 将路由模式转换为正则表达式
        // :param → (?<param>[^/?#]+)
        var regexString = "^"
        var namedGroups: [(index: Int, name: String)] = []

        let parts = pattern.split(separator: "/", omittingEmptySubsequences: false)
        for (i, part) in parts.enumerated() {
            if part.hasPrefix(":") {
                let paramName = String(part.dropFirst())
                namedGroups.append((index: namedGroups.count, name: paramName))
                regexString += "/(?<\(paramName)>[^/?#]+)"
            } else if !part.isEmpty {
                regexString += (i == 0 ? "" : "/") + NSRegularExpression.escapedPattern(for: String(part))
            }
        }
        regexString += "(?:\\?.*)?$"

        // 使用纯正则匹配（不用 named capture groups，兼容性更好）
        var simpleRegex = "^"
        var groupIndex = 0
        for (i, part) in parts.enumerated() {
            if part.hasPrefix(":") {
                groupIndex += 1
                simpleRegex += "/([^/?#]+)"
            } else if !part.isEmpty {
                simpleRegex += (i == 0 ? "" : "/") + NSRegularExpression.escapedPattern(for: String(part))
            }
        }
        simpleRegex += "(?:\\?.*)?$"

        guard let regex = try? NSRegularExpression(pattern: simpleRegex, options: []) else { return nil }
        return regex
    }
}

// MARK: - NSRegularExpression Named Groups Helper

private extension NSRegularExpression {
    /// 提取命名捕获组名称（简化版，仅用于内部路由匹配）
    var namedCaptureGroups: [String] {
        var groups: [String] = []
        let pattern = self.pattern
        // 简单提取括号组
        var depth = 0
        var current = ""
        for char in pattern {
            if char == "(" {
                depth += 1
                if depth == 1 {
                    current = ""
                }
            } else if char == ")" {
                if depth == 1 && !current.hasPrefix("?") {
                    groups.append("param_\(groups.count)")
                }
                depth = max(0, depth - 1)
            } else if depth == 1 {
                current.append(char)
            }
        }
        return groups
    }
}
