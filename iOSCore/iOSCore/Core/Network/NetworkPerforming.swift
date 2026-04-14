//
//  NetworkPerforming.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Alamofire
import Foundation

/// 网络请求协议（便于测试和替换实现）
public protocol NetworkPerforming: Sendable {
    /// GET 请求
    func get(_ url: String, parameters: Parameters?, headers: HTTPHeaders?) async throws -> Data

    /// GET 请求并解码
    func get<T: Decodable>(_ url: String, parameters: Parameters?, headers: HTTPHeaders?) async throws -> T

    /// POST 请求
    func post(_ url: String, parameters: Parameters?, headers: HTTPHeaders?) async throws -> Data

    /// POST 请求并解码
    func post<T: Decodable>(_ url: String, parameters: Parameters?, headers: HTTPHeaders?) async throws -> T

    /// 通用请求
    func request(_ url: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders?) async throws -> Data

    /// 通用请求并解码
    func request<T: Decodable>(_ url: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders?) async throws -> T
}

/// 默认实现
extension NetworkPerforming {
    public func get(_ url: String, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) async throws -> Data {
        try await request(url, method: .get, parameters: parameters, headers: headers)
    }

    public func get<T: Decodable>(_ url: String, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) async throws -> T {
        try await request(url, method: .get, parameters: parameters, headers: headers)
    }

    public func post(_ url: String, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) async throws -> Data {
        try await request(url, method: .post, parameters: parameters, headers: headers)
    }

    public func post<T: Decodable>(_ url: String, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) async throws -> T {
        try await request(url, method: .post, parameters: parameters, headers: headers)
    }
}
