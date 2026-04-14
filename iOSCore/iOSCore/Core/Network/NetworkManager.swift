//
//  NetworkManager.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/3/27.
//

import Alamofire
import Foundation

/// 网络请求错误
public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case unknown
}

/// 网络请求管理器
public final class NetworkManager: NetworkPerforming {

    public static let shared = NetworkManager()

    /// 是否自动附加 BasicSetting 公共参数，默认 true
    public var attachBasicParameters: Bool = true

    private init() {}

    // MARK: - GET 请求

    /// GET 请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameters: 参数
    ///   - headers: 请求头
    /// - Returns: 响应数据
    @discardableResult
    public func get(
        _ url: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> Data {
        try await request(url, method: .get, parameters: parameters, headers: headers)
    }

    /// GET 请求并解码
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameters: 参数
    ///   - headers: 请求头
    /// - Returns: 解码后的对象
    public func get<T: Decodable>(
        _ url: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        try await request(url, method: .get, parameters: parameters, headers: headers)
    }

    // MARK: - POST 请求

    /// POST 请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameters: 参数
    ///   - headers: 请求头
    /// - Returns: 响应数据
    @discardableResult
    public func post(
        _ url: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> Data {
        try await request(url, method: .post, parameters: parameters, headers: headers)
    }

    /// POST 请求并解码
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameters: 参数
    ///   - headers: 请求头
    /// - Returns: 解码后的对象
    public func post<T: Decodable>(
        _ url: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        try await request(url, method: .post, parameters: parameters, headers: headers)
    }

    // MARK: - 通用请求

    /// 通用请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - method: 请求方法
    ///   - parameters: 参数
    ///   - headers: 请求头
    /// - Returns: 响应数据
    public func request(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> Data {
        var mergedParams: Parameters = attachBasicParameters
            ? BasicSetting.shared.parameters().mapValues { $0 as Any }
            : [:]
        if let parameters = parameters {
            mergedParams.merge(parameters) { _, new in new }
        }

        let response = try await AF.request(
            url,
            method: method,
            parameters: mergedParams,
            headers: headers
        )
        .validate()
        .serializingData()
        .response

        switch response.result {
        case .success(let data):
            return data
        case .failure(let error):
            throw NetworkError.networkError(error)
        }
    }

    /// 通用请求并解码
    /// - Parameters:
    ///   - url: 请求地址
    ///   - method: 请求方法
    ///   - parameters: 参数
    ///   - headers: 请求头
    /// - Returns: 解码后的对象
    public func request<T: Decodable>(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        let data = try await request(url, method: method, parameters: parameters, headers: headers)

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    // MARK: - 上传

    /// 上传文件
    /// - Parameters:
    ///   - url: 上传地址
    ///   - fileURL: 文件路径
    ///   - headers: 请求头
    /// - Returns: 响应数据
    public func upload(
        _ url: String,
        fileURL: URL,
        headers: HTTPHeaders? = nil
    ) async throws -> Data {
        let response = try await AF.upload(fileURL, to: url, headers: headers)
            .validate()
            .serializingData()
            .response

        switch response.result {
        case .success(let data):
            return data
        case .failure(let error):
            throw NetworkError.networkError(error)
        }
    }

    // MARK: - 下载

    /// 下载文件
    /// - Parameters:
    ///   - url: 下载地址
    ///   - destination: 目标路径
    ///   - progress: 下载进度回调
    /// - Returns: 文件路径
    @discardableResult
    public func download(
        _ url: String,
        to destination: URL,
        progress: ((Double) -> Void)? = nil
    ) async throws -> URL {
        let downloadDestination: DownloadRequest.Destination = { _, _ in
            return (destination, [.removePreviousFile, .createIntermediateDirectories])
        }

        let request = AF.download(url, to: downloadDestination)
            .validate()

        if let progressHandler = progress {
            request.downloadProgress { progressHandler($0.fractionCompleted) }
        }

        let fileURL = try await request.serializingDownloadedFileURL().value

        return fileURL
    }
}
